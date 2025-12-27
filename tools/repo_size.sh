#!/bin/bash
# repo_size: 显示仓库真实大小（排除 .gitignore 和 .git 等文件）
# 功能：
#   1. 读取当前目录的 .gitignore 文件
#   2. 排除 .git 目录和其他 Git 相关文件
#   3. 可选：排除子 Git 仓库
#   4. 计算并显示目录的真实大小
#
# 用法：
#   repo:size                    # 分析当前目录
#   repo:size /path/to/dir       # 分析指定目录
#   repo:size --exclude-subrepos # 排除子仓库
#   repo:size -e                 # 排除子仓库（简写）

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 解析参数
EXCLUDE_SUBREPOS=false
TARGET_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --exclude-subrepos|-e|--exclude-sub)
            EXCLUDE_SUBREPOS=true
            shift
            ;;
        --help|-h)
            echo "用法: repo:size [选项] [目录]"
            echo ""
            echo "选项:"
            echo "  -e, --exclude-subrepos, --exclude-sub  排除子 Git 仓库"
            echo "  -h, --help                             显示帮助信息"
            echo ""
            echo "示例:"
            echo "  repo:size                              # 分析当前目录"
            echo "  repo:size /path/to/dir                  # 分析指定目录"
            echo "  repo:size --exclude-subrepos            # 排除子仓库"
            exit 0
            ;;
        -*)
            echo -e "${RED}错误：未知选项 $1${NC}"
            echo "使用 --help 查看帮助信息"
            exit 1
            ;;
        *)
            if [ -z "$TARGET_DIR" ]; then
                TARGET_DIR="$1"
            else
                echo -e "${RED}错误：只能指定一个目录${NC}"
                exit 1
            fi
            shift
            ;;
    esac
done

# 如果没有指定目录，使用当前目录
TARGET_DIR="${TARGET_DIR:-$(pwd)}"

# 转换为绝对路径
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")"

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}错误：目录不存在: $TARGET_DIR${NC}"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}仓库真实大小分析${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${CYAN}目录: $TARGET_DIR${NC}"
if [ "$EXCLUDE_SUBREPOS" = true ]; then
    echo -e "${YELLOW}模式: 排除子 Git 仓库${NC}"
fi
echo ""

# 切换到目标目录
cd "$TARGET_DIR" || exit 1

# 检测子 Git 仓库
SUBREPOS=()
if [ "$EXCLUDE_SUBREPOS" = true ]; then
    echo -e "${CYAN}正在检测子 Git 仓库...${NC}"
    # 查找所有包含 .git 的子目录（排除当前目录的 .git）
    while IFS= read -r subdir; do
        if [ -d "$subdir/.git" ] && [ "$subdir" != "." ]; then
            SUBREPOS+=("$subdir")
        fi
    done < <(find . -type d -name ".git" -not -path "./.git" 2>/dev/null | sed 's|/.git$||' | sed 's|^\./||')
    
    if [ ${#SUBREPOS[@]} -gt 0 ]; then
        echo -e "${YELLOW}发现 ${#SUBREPOS[@]} 个子仓库，将被排除:${NC}"
        for subrepo in "${SUBREPOS[@]}"; do
            echo -e "  ${CYAN}•${NC} $subrepo"
        done
        echo ""
    else
        echo -e "${GREEN}✓ 未发现子 Git 仓库${NC}"
        echo ""
    fi
fi

# 方法1: 如果是 Git 仓库，使用 git ls-files（最准确）
if [ -d ".git" ] && command -v git >/dev/null 2>&1; then
    echo -e "${GREEN}✓ 检测到 Git 仓库，使用 git ls-files 计算${NC}"
    echo ""
    
    # 获取所有被 Git 跟踪的文件
    TRACKED_FILES=$(git ls-files 2>/dev/null)
    
    if [ -n "$TRACKED_FILES" ]; then
        # 如果排除子仓库，过滤掉子仓库中的文件
        if [ "$EXCLUDE_SUBREPOS" = true ] && [ ${#SUBREPOS[@]} -gt 0 ]; then
            FILTERED_FILES=""
            while IFS= read -r file; do
                # 检查文件是否在子仓库中
                in_subrepo=false
                for subrepo in "${SUBREPOS[@]}"; do
                    if [[ "$file" == "$subrepo"/* ]]; then
                        in_subrepo=true
                        break
                    fi
                done
                if [ "$in_subrepo" = false ]; then
                    FILTERED_FILES="${FILTERED_FILES}${file}"$'\n'
                fi
            done <<< "$TRACKED_FILES"
            TRACKED_FILES="$FILTERED_FILES"
        fi
        
        # 计算总大小
        TOTAL_SIZE=0
        FILE_COUNT=0
        
        while IFS= read -r file; do
            if [ -n "$file" ] && [ -f "$file" ]; then
                # 获取文件大小（macOS 和 Linux 兼容）
                size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
                TOTAL_SIZE=$((TOTAL_SIZE + size))
                FILE_COUNT=$((FILE_COUNT + 1))
            fi
        done <<< "$TRACKED_FILES"
        
        # 计算目录数量（从文件路径提取，排除子仓库）
        DIR_PATHS=$(echo "$TRACKED_FILES" | sed 's|/[^/]*$||' | sort -u)
        if [ "$EXCLUDE_SUBREPOS" = true ] && [ ${#SUBREPOS[@]} -gt 0 ]; then
            for subrepo in "${SUBREPOS[@]}"; do
                DIR_PATHS=$(echo "$DIR_PATHS" | grep -v "^$subrepo" | grep -v "^$subrepo/")
            done
        fi
        DIR_COUNT=$(echo "$DIR_PATHS" | grep -v '^$' | wc -l | tr -d ' ')
        
        # 显示 .gitignore 信息
        if [ -f ".gitignore" ]; then
            IGNORE_COUNT=$(grep -v '^#' .gitignore | grep -v '^$' | wc -l | tr -d ' ')
            echo -e "${CYAN}.gitignore 规则数:${NC} ${IGNORE_COUNT}"
        fi
    else
        echo -e "${YELLOW}⚠ Git 仓库中没有被跟踪的文件${NC}"
        TOTAL_SIZE=0
        FILE_COUNT=0
        DIR_COUNT=0
    fi
else
    # 方法2: 不是 Git 仓库，使用 find + .gitignore 排除
    echo -e "${YELLOW}⚠ 不是 Git 仓库，使用 .gitignore 规则排除文件${NC}"
    echo ""
    
    # 查找 .gitignore 文件
    GITIGNORE_FILE=""
    CURRENT_DIR="$TARGET_DIR"
    
    while [ "$CURRENT_DIR" != "/" ]; do
        if [ -f "$CURRENT_DIR/.gitignore" ]; then
            GITIGNORE_FILE="$CURRENT_DIR/.gitignore"
            break
        fi
        CURRENT_DIR="$(dirname "$CURRENT_DIR")"
    done
    
    # 使用 find 查找文件，排除 .git 目录
    # 先排除 .git 目录和其他系统文件
    FIND_ARGS=(
        "." -type f
        -not -path "*/.git/*"
        -not -name ".gitignore"
        -not -name ".gitattributes"
        -not -name ".DS_Store"
        -not -name ".DS_Store?"
        -not -name "._*"
    )
    
    # 如果排除子仓库，添加排除路径
    if [ "$EXCLUDE_SUBREPOS" = true ] && [ ${#SUBREPOS[@]} -gt 0 ]; then
        for subrepo in "${SUBREPOS[@]}"; do
            FIND_ARGS+=(-not -path "./$subrepo/*")
        done
    fi
    
    FILES=$(find "${FIND_ARGS[@]}" 2>/dev/null)
    
    # 如果有 .gitignore，进一步过滤
    if [ -n "$GITIGNORE_FILE" ]; then
        echo -e "${GREEN}✓ 找到 .gitignore: $GITIGNORE_FILE${NC}"
        echo ""
        
        # 创建临时脚本用于过滤
        FILTER_SCRIPT=$(mktemp)
        cat > "$FILTER_SCRIPT" << 'FILTER_EOF'
#!/bin/bash
# 过滤脚本：根据 .gitignore 规则排除文件

GITIGNORE_FILE="$1"
shift

# 读取 .gitignore 规则
declare -a PATTERNS
while IFS= read -r line || [ -n "$line" ]; do
    line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ -z "$line" ] || [[ "$line" == \#* ]] || [[ "$line" == !* ]]; then
        continue
    fi
    pattern="${line#/}"
    if [ -n "$pattern" ]; then
        PATTERNS+=("$pattern")
    fi
done < "$GITIGNORE_FILE"

# 检查文件是否匹配任何模式
should_exclude() {
    local file="$1"
    local basename=$(basename "$file")
    
    for pattern in "${PATTERNS[@]}"; do
        # 简单匹配：如果文件名或路径包含模式
        if [[ "$file" == *"$pattern"* ]] || [[ "$basename" == "$pattern" ]]; then
            return 0
        fi
        # 支持通配符（简单实现）
        case "$basename" in
            $pattern) return 0 ;;
        esac
    done
    return 1
}

# 过滤文件列表
while IFS= read -r file; do
    if ! should_exclude "$file"; then
        echo "$file"
    fi
done
FILTER_EOF
        chmod +x "$FILTER_SCRIPT"
        
        # 使用过滤脚本
        FILES=$(echo "$FILES" | "$FILTER_SCRIPT" "$GITIGNORE_FILE")
        rm -f "$FILTER_SCRIPT"
    else
        echo -e "${YELLOW}⚠ 未找到 .gitignore 文件${NC}"
        echo ""
    fi
    
    # 计算总大小
    TOTAL_SIZE=0
    FILE_COUNT=0
    
    if [ -n "$FILES" ]; then
        while IFS= read -r file; do
            if [ -f "$file" ]; then
                size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
                TOTAL_SIZE=$((TOTAL_SIZE + size))
                FILE_COUNT=$((FILE_COUNT + 1))
            fi
        done <<< "$FILES"
    fi
    
    # 计算目录数量
    DIR_FIND_ARGS=(
        "." -type d
        -not -path "*/.git/*"
        -not -name ".git"
    )
    
    # 如果排除子仓库，添加排除路径
    if [ "$EXCLUDE_SUBREPOS" = true ] && [ ${#SUBREPOS[@]} -gt 0 ]; then
        for subrepo in "${SUBREPOS[@]}"; do
            DIR_FIND_ARGS+=(-not -path "./$subrepo" -not -path "./$subrepo/*")
        done
    fi
    
    DIRS=$(find "${DIR_FIND_ARGS[@]}" 2>/dev/null)
    DIR_COUNT=0
    if [ -n "$DIRS" ]; then
        DIR_COUNT=$(echo "$DIRS" | wc -l | tr -d ' ')
    fi
fi

# 格式化大小显示
format_size() {
    local size=$1
    if command -v awk >/dev/null 2>&1; then
        if [ "$size" -ge 1073741824 ]; then
            awk "BEGIN {printf \"%.2f GB\", $size / 1073741824}"
        elif [ "$size" -ge 1048576 ]; then
            awk "BEGIN {printf \"%.2f MB\", $size / 1048576}"
        elif [ "$size" -ge 1024 ]; then
            awk "BEGIN {printf \"%.2f KB\", $size / 1024}"
        else
            echo "${size} B"
        fi
    else
        # 简单的格式化（无 awk）
        if [ "$size" -ge 1073741824 ]; then
            printf "%.2f GB" $(echo "scale=2; $size / 1073741824" | bc 2>/dev/null || echo "0")
        elif [ "$size" -ge 1048576 ]; then
            printf "%.2f MB" $(echo "scale=2; $size / 1048576" | bc 2>/dev/null || echo "0")
        elif [ "$size" -ge 1024 ]; then
            printf "%.2f KB" $(echo "scale=2; $size / 1024" | bc 2>/dev/null || echo "0")
        else
            echo "${size} B"
        fi
    fi
}

FORMATTED_SIZE=$(format_size "$TOTAL_SIZE")

# 显示结果
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}统计结果${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${CYAN}总大小:${NC} ${YELLOW}$FORMATTED_SIZE${NC} (${TOTAL_SIZE} 字节)"
echo -e "${CYAN}文件数量:${NC} ${YELLOW}$FILE_COUNT${NC}"
echo -e "${CYAN}目录数量:${NC} ${YELLOW}$DIR_COUNT${NC}"
echo ""
echo -e "${GREEN}========================================${NC}"
