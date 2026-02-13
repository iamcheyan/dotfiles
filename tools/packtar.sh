#!/usr/bin/env bash
# 現在のディレクトリをtar.gzでパッケージ化し、親ディレクトリに配置する
# 使用方法: pack_tar.sh [--day <n>] <filename>

set -euo pipefail

# 引数チェック
DAY_RANGE=1
POSITIONAL_ARGS=()
while [ $# -gt 0 ]; do
    case "$1" in
        --day)
            shift
            if [ $# -eq 0 ] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
                echo "Error: --day には正の整数を指定してください" >&2
                exit 1
            fi
            DAY_RANGE="$1"
            shift
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

if [ ${#POSITIONAL_ARGS[@]} -gt 0 ]; then
    set -- "${POSITIONAL_ARGS[@]}"
fi

if [ $# -eq 0 ]; then
    echo "Error: ファイル名を指定してください" >&2
    echo "使用方法: $0 [--today|-t] <filename>" >&2
    exit 1
fi

FILENAME="$1"

# 現在のディレクトリを取得
CURRENT_DIR="$(pwd)"

# 親ディレクトリを取得
PARENT_DIR="$(dirname "$CURRENT_DIR")"

# tar.gzファイルの出力パス
OUTPUT_FILE="${PARENT_DIR}/${FILENAME}.tar.gz"

# .tar-excludeファイルのパス（現在のディレクトリ内）
EXCLUDE_FILE="${CURRENT_DIR}/.tar-exclude"
GITIGNORE_FILE="${CURRENT_DIR}/.gitignore"
GITIGNORE_EXCLUDE_FILE=""
GIT_INCLUDE_FILE=""
USE_GIT_FILELIST=0
TAR_SUPPORTS_NULL=0
TODAY_INCLUDE_FILE=""
TODAY_MARKER_FILE=""
CLEANUP_FILES=()

cleanup_tmp() {
    if [ ${#CLEANUP_FILES[@]} -gt 0 ]; then
        rm -f "${CLEANUP_FILES[@]}"
    fi
}
trap cleanup_tmp EXIT

if command -v rg >/dev/null 2>&1; then
    TAR_HELP_MATCHER=(rg -q --)
else
    TAR_HELP_MATCHER=(grep -q --)
fi

if tar --help 2>/dev/null | "${TAR_HELP_MATCHER[@]}" "--null"; then
    TAR_SUPPORTS_NULL=1
fi

# tarコマンドを実行
echo "パッケージ化中: ${CURRENT_DIR} -> ${OUTPUT_FILE}"

# tarコマンドの引数を構築（順序が重要）
# 正しい順序: オプション -> 出力ファイル -> --exclude -> --exclude-from -> -C -> アーカイブパス
TAR_ARGS=(
    czf "${OUTPUT_FILE}"
    --exclude=".git"
    --exclude=".git/*"
)

# .tar-excludeファイルが存在する場合は追加で除外（-Cの前に配置）
if [ -f "$EXCLUDE_FILE" ]; then
    echo "除外ファイル: ${EXCLUDE_FILE}"
    TAR_ARGS+=(--exclude-from="${EXCLUDE_FILE}")
fi

# .gitignore が存在する場合はそのルールも適用
if [ -f "$GITIGNORE_FILE" ]; then
    echo "検出: ${GITIGNORE_FILE}（gitignore ルールで除外します）"
    if command -v git >/dev/null 2>&1 && [ -d "${CURRENT_DIR}/.git" ]; then
        GITIGNORE_MATCHES="$(git -C "${CURRENT_DIR}" ls-files -i -o --exclude-standard --directory)"
        if [ -n "${GITIGNORE_MATCHES}" ]; then
            echo "除外対象（gitignore 由来）:"
            echo "${GITIGNORE_MATCHES}"
        else
            echo "除外対象（gitignore 由来）: なし"
        fi
        USE_GIT_FILELIST=1
        GIT_INCLUDE_FILE="$(mktemp)"
        CLEANUP_FILES+=("${GIT_INCLUDE_FILE}")
        if [ "${TAR_SUPPORTS_NULL}" -eq 1 ]; then
            git -C "${CURRENT_DIR}" ls-files -z --cached --others --exclude-standard | \
                while IFS= read -r -d '' path; do
                    if [ -e "${CURRENT_DIR}/${path}" ]; then
                        printf '%s\0' "${path}"
                    fi
                done > "${GIT_INCLUDE_FILE}"
        else
            echo "注意: tar に --null が無いため、空白を含むパスは正しく扱えません" >&2
            git -C "${CURRENT_DIR}" ls-files --cached --others --exclude-standard | \
                while IFS= read -r path; do
                    if [ -e "${CURRENT_DIR}/${path}" ]; then
                        printf '%s\n' "${path}"
                    fi
                done > "${GIT_INCLUDE_FILE}"
        fi
        echo "除外ルール: git ls-files でファイル一覧を生成"
    else
        echo "注意: git が使えないため、除外対象の一覧は表示できません" >&2
        if tar --help 2>/dev/null | "${TAR_HELP_MATCHER[@]}" "--exclude-vcs-ignores"; then
            echo "除外ルール: tar --exclude-vcs-ignores を使用"
            TAR_ARGS+=(--exclude-vcs-ignores)
        else
            echo "注意: .gitignore を検出しましたが、tar/git のサポート不足のため適用できません" >&2
        fi
    fi
fi

# ディレクトリ変更とアーカイブパスを最後に追加
if [ "${DAY_RANGE}" -gt 0 ]; then
    TODAY_MARKER_FILE="$(mktemp)"
    CLEANUP_FILES+=("${TODAY_MARKER_FILE}")
    if date -d "now - ${DAY_RANGE} days" >/dev/null 2>&1; then
        touch -d "now - ${DAY_RANGE} days" "${TODAY_MARKER_FILE}"
    elif date -v0H -v0M -v0S >/dev/null 2>&1; then
        touch -t "$(date -v-"${DAY_RANGE}"d '+%Y%m%d%H%M.%S')" "${TODAY_MARKER_FILE}"
    else
        touch "${TODAY_MARKER_FILE}"
    fi

    TODAY_INCLUDE_FILE="$(mktemp)"
    CLEANUP_FILES+=("${TODAY_INCLUDE_FILE}")
    if command -v git >/dev/null 2>&1 && [ -d "${CURRENT_DIR}/.git" ]; then
        if [ "${TAR_SUPPORTS_NULL}" -eq 1 ]; then
            git -C "${CURRENT_DIR}" ls-files -z --cached --others --exclude-standard | \
                while IFS= read -r -d '' path; do
                    if [ -e "${CURRENT_DIR}/${path}" ] && [ "${CURRENT_DIR}/${path}" -nt "${TODAY_MARKER_FILE}" ]; then
                        printf '%s\0' "${path}"
                    fi
                done > "${TODAY_INCLUDE_FILE}"
        else
            echo "注意: tar に --null が無いため、空白を含むパスは正しく扱えません" >&2
            git -C "${CURRENT_DIR}" ls-files --cached --others --exclude-standard | \
                while IFS= read -r path; do
                    if [ -e "${CURRENT_DIR}/${path}" ] && [ "${CURRENT_DIR}/${path}" -nt "${TODAY_MARKER_FILE}" ]; then
                        printf '%s\n' "${path}"
                    fi
                done > "${TODAY_INCLUDE_FILE}"
        fi
        echo "除外ルール: git ls-files でファイル一覧を生成（直近 ${DAY_RANGE} 日）"
    else
        if [ "${TAR_SUPPORTS_NULL}" -eq 1 ]; then
            find . -path "./.git" -prune -o -type f -newer "${TODAY_MARKER_FILE}" -print0 > "${TODAY_INCLUDE_FILE}"
        else
            echo "注意: tar に --null が無いため、空白を含むパスは正しく扱えません" >&2
            find . -path "./.git" -prune -o -type f -newer "${TODAY_MARKER_FILE}" -print > "${TODAY_INCLUDE_FILE}"
        fi
    fi

    if [ ! -s "${TODAY_INCLUDE_FILE}" ]; then
        echo "エラー: 直近 ${DAY_RANGE} 日に更新されたファイルがありません" >&2
        exit 1
    fi

    TAR_ARGS+=(-C "${CURRENT_DIR}")
    if [ "${TAR_SUPPORTS_NULL}" -eq 1 ]; then
        TAR_ARGS+=(--null -T "${TODAY_INCLUDE_FILE}")
    else
        TAR_ARGS+=(-T "${TODAY_INCLUDE_FILE}")
    fi
elif [ "${USE_GIT_FILELIST}" -eq 1 ]; then
    TAR_ARGS+=(-C "${CURRENT_DIR}")
    if [ "${TAR_SUPPORTS_NULL}" -eq 1 ]; then
        TAR_ARGS+=(--null -T "${GIT_INCLUDE_FILE}")
    else
        TAR_ARGS+=(-T "${GIT_INCLUDE_FILE}")
    fi
else
    TAR_ARGS+=(
        -C "${CURRENT_DIR}" .
    )
fi

tar "${TAR_ARGS[@]}"

# ファイル情報を表示
if [ -f "${OUTPUT_FILE}" ]; then
    echo "完了: ${OUTPUT_FILE}"
    echo ""
    echo "ファイル情報:"
    echo "  パス: ${OUTPUT_FILE}"
    
    # サイズ（人間が読みやすい形式とバイト数）
    FILE_SIZE_H=$(ls -lh "${OUTPUT_FILE}" | awk '{print $5}')
    FILE_SIZE_B=$(stat -c '%s' "${OUTPUT_FILE}" 2>/dev/null || stat -f '%z' "${OUTPUT_FILE}" 2>/dev/null || ls -l "${OUTPUT_FILE}" | awk '{print $5}')
    echo "  サイズ: ${FILE_SIZE_H} (${FILE_SIZE_B} バイト)"
    
    # 作成日時
    if stat -c '%y' "${OUTPUT_FILE}" >/dev/null 2>&1; then
        # Linux
        FILE_DATE=$(stat -c '%y' "${OUTPUT_FILE}" | cut -d'.' -f1 | sed 's/ /  /')
    elif stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' "${OUTPUT_FILE}" >/dev/null 2>&1; then
        # macOS
        FILE_DATE=$(stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' "${OUTPUT_FILE}")
    else
        # フォールバック
        FILE_DATE=$(ls -l --time-style=long-iso "${OUTPUT_FILE}" 2>/dev/null | awk '{print $6, $7}' || date '+%Y-%m-%d %H:%M:%S')
    fi
    echo "  作成日時: ${FILE_DATE}"
    
    # パーミッション
    if stat -c '%a' "${OUTPUT_FILE}" >/dev/null 2>&1; then
        # Linux
        FILE_PERM=$(stat -c '%a (%A)' "${OUTPUT_FILE}")
    elif stat -f '%OLp' "${OUTPUT_FILE}" >/dev/null 2>&1; then
        # macOS
        FILE_PERM=$(stat -f '%OLp (%Sp)' "${OUTPUT_FILE}")
    else
        FILE_PERM=$(ls -l "${OUTPUT_FILE}" | awk '{print $1}')
    fi
    echo "  パーミッション: ${FILE_PERM}"
    
    # 所有者
    if stat -c '%U:%G' "${OUTPUT_FILE}" >/dev/null 2>&1; then
        # Linux
        FILE_OWNER=$(stat -c '%U:%G' "${OUTPUT_FILE}")
    elif stat -f '%Su:%Sg' "${OUTPUT_FILE}" >/dev/null 2>&1; then
        # macOS
        FILE_OWNER=$(stat -f '%Su:%Sg' "${OUTPUT_FILE}")
    else
        FILE_OWNER=$(ls -l "${OUTPUT_FILE}" | awk '{print $3":"$4}')
    fi
    echo "  所有者: ${FILE_OWNER}"
else
    echo "エラー: ファイルが作成されませんでした" >&2
    exit 1
fi
