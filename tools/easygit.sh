#!/bin/bash

# easygit - Git 仓库管理的便利ツール

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 現在のディレクトリパスを取得
CURRENT_DIR=$(pwd)
DIR_NAME=$(basename "$CURRENT_DIR")

# ヘルプメッセージを表示
show_help() {
    echo -e "${CYAN}easygit - Git 仓库管理的便利工具${NC}"
    echo ""
    echo "使用方法: easygit [command]"
    echo ""
    echo "コマンド:"
    echo "  init        初始化新仓库并推送到 GitHub（可选择公开/私有）"
    echo "  set-remote  重新指定远程仓库地址（可直接传入 URL）"
    echo "  push        普通推送（提交并推送到远程）"
    echo "  pull        普通拉取（从远程拉取更新）"
    echo "  force-push  强制推送（使用当前时间和机器码作为提交信息，强制覆盖远程）"
    echo "  force-pull  强制恢复（删除本地变更，用远程覆盖本地）"
    echo "  info        显示仓库信息（如果不是仓库，提示初始化）"
    echo "  help        显示此帮助信息"
    echo ""
    echo "例:"
    echo "  easygit init        # 初始化并推送新仓库"
    echo "  easygit set-remote https://github.com/username/repo.git  # 直接指定远程仓库"
    echo "  easygit set-remote  # 交互式输入远程仓库地址"
    echo "  easygit push         # 普通推送"
    echo "  easygit pull         # 普通拉取"
    echo "  easygit force-push   # 强制推送覆盖远程"
    echo "  easygit force-pull  # 强制拉取覆盖本地"
    echo "  easygit info        # 显示仓库信息"
}

# GitHub CLI が実際に使えるかテスト（実測）
check_gh_available() {
    if ! command -v gh >/dev/null 2>&1; then
        return 1
    fi
    # 実測: gh api user が成功するか
    if gh api user >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# GitHubのユーザー名を取得（gh優先、フォールバック）
get_github_user() {
    local user=""
    
    # 1. GitHub CLI から取得（最優先）
    if check_gh_available; then
        user=$(gh api user --jq .login 2>/dev/null)
        if [ -n "$user" ]; then
            echo "$user"
            return 0
        fi
    fi
    
    # 2. 環境変数
    if [ -n "${GITHUB_USER:-}" ]; then
        echo "$GITHUB_USER"
        return 0
    fi
    
    # 3. 設定ファイル
    local CONFIG_FILE="$HOME/.github_config"
    if [ -f "$CONFIG_FILE" ]; then
        user=$(bash -c "source '$CONFIG_FILE' 2>/dev/null; echo \${GITHUB_USER:-}" 2>/dev/null)
        if [ -n "$user" ]; then
            echo "$user"
            return 0
        fi
    fi
    
    # 4. Git設定
    user=$(git config --global user.name 2>/dev/null)
    if [ -n "$user" ]; then
        echo "$user"
        return 0
    fi
    
    # 5. 手動入力
    echo -e "${YELLOW}GitHubユーザー名を入力してください:${NC}"
    read user
    echo "$user"
}

# GitHubリポジトリを作成（gh優先、失敗時は即終了）
create_github_repo() {
    local repo_name=$1
    local visibility=$2
    
    # GitHub CLI が実際に使えるかテスト（実測）
    if check_gh_available; then
        # 既存のリポジトリをチェック
        if gh repo view "$repo_name" >/dev/null 2>&1; then
            REPO_INFO=$(gh repo view "$repo_name" --json name,isPrivate,url -q '{name, visibility: (if .isPrivate then "private" else "public" end), url}' 2>/dev/null)
            if [ -n "$REPO_INFO" ]; then
                REPO_URL=$(echo "$REPO_INFO" | grep -o '"url":"[^"]*"' | cut -d'"' -f4)
                REPO_VISIBILITY=$(echo "$REPO_INFO" | grep -o '"visibility":"[^"]*"' | cut -d'"' -f4)
                echo -e "${YELLOW}⚠️  リポジトリ '$repo_name' は既に存在します${NC}"
                echo -e "${CYAN}   リポジトリURL: $REPO_URL${NC}"
                echo -e "${CYAN}   公開設定: $REPO_VISIBILITY${NC}"
            else
                echo -e "${YELLOW}⚠️  リポジトリ '$repo_name' は既に存在します${NC}"
            fi
            echo -e "${YELLOW}既存のリポジトリを使用して続行しますか？ (y/n):${NC}"
            read USE_EXISTING
            if [ "$USE_EXISTING" != "y" ] && [ "$USE_EXISTING" != "Y" ]; then
                echo -e "${YELLOW}操作がキャンセルされました${NC}"
                return 2
            fi
            echo -e "${GREEN}既存のリポジトリを使用します${NC}"
            return 0
        fi
        
        # 新規リポジトリを作成
        echo -e "${GREEN}GitHub CLIを使用してリポジトリを作成中: $repo_name${NC}"
        local CREATE_OUTPUT
        if [ "$visibility" = "private" ]; then
            CREATE_OUTPUT=$(gh repo create "$repo_name" --private --confirm 2>&1)
            CREATE_EXIT=$?
        else
            CREATE_OUTPUT=$(gh repo create "$repo_name" --public --confirm 2>&1)
            CREATE_EXIT=$?
        fi
        
        if [ $CREATE_EXIT -eq 0 ]; then
            echo -e "${GREEN}リポジトリが正常に作成されました！${NC}"
            return 0
        else
            # gh が失敗した場合、エラー内容を確認
            echo -e "${RED}GitHub CLIでリポジトリの作成に失敗しました${NC}"
            echo "$CREATE_OUTPUT" | head -5
            
            # 401 エラーの場合
            if echo "$CREATE_OUTPUT" | grep -q "401\|Bad credentials\|authentication"; then
                echo -e "${YELLOW}認証エラーが発生しました${NC}"
                echo -e "${CYAN}解決方法:${NC}"
                echo "  1. gh auth logout"
                echo "  2. gh auth login"
                echo "  3. 再度実行してください"
            fi
            
            echo -e "${RED}リポジトリの作成を中止します${NC}"
            return 1
        fi
    fi
    
    # GitHub CLI が使えない場合
    echo -e "${RED}エラー: GitHub CLI (gh) が利用できません${NC}"
    echo -e "${YELLOW}解決方法:${NC}"
    echo "  1. GitHub CLI をインストール:"
    echo "     • macOS: brew install gh"
    echo "     • Linux: 各ディストリビューションのパッケージマネージャーでインストール"
    echo "  2. 認証: gh auth login"
    echo "  3. 再度実行してください"
    echo ""
    echo -e "${YELLOW}注意: API モード（curl + token）は自動フォールバックしません${NC}"
    echo -e "${YELLOW}      SSL 証明書の問題がある環境では推奨されません${NC}"
    return 1
}

# 機能1: 新規リポジトリの初期化とプッシュ
cmd_init() {
    # Git初期化
    if [ ! -d ".git" ]; then
        echo -e "${GREEN}Gitリポジトリを初期化中...${NC}"
        git init
    else
        echo -e "${YELLOW}既にGitリポジトリが初期化されています${NC}"
    fi
    
    # .gitignoreが存在しない場合は自動的に作成（常用テンプレート付き）
    if [ ! -f ".gitignore" ]; then
        echo -e "${GREEN}.gitignoreファイルを自動作成中...${NC}"
        cat > .gitignore << 'GITIGNORE_EOF'
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Editor directories and files
.idea/
.vscode/
*.swp
*.swo
*~
.project
.classpath
.settings/

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Dependency directories
node_modules/
vendor/
bower_components/

# Build outputs
dist/
build/
*.o
*.a
*.so
*.dylib
*.exe
*.out

# Environment variables
.env
.env.local
.env.*.local

# Temporary files
*.tmp
*.temp
*.cache
.cache/

# Package manager lock files (uncomment if needed)
# package-lock.json
# yarn.lock
# Pipfile.lock

# IDE and editor files
*.sublime-project
*.sublime-workspace
*.code-workspace

# System files
.directory
.Trash-*
GITIGNORE_EOF
        echo -e "${GREEN}.gitignoreファイルを作成しました（常用テンプレート付き）${NC}"
    fi
    
    # GitHub ユーザー名を取得
    GITHUB_USER=$(get_github_user)
    export GITHUB_USER
    
    # リポジトリ名を決定
    REPO_NAME="$DIR_NAME"
    echo -e "${GREEN}リポジトリ名: $REPO_NAME${NC}"
    echo -e "${YELLOW}この名前で作成しますか？ (y/n/新しい名前を直接入力):${NC}"
    read USER_INPUT
    
    if [ "$USER_INPUT" = "n" ] || [ "$USER_INPUT" = "N" ]; then
        while true; do
            echo -e "${YELLOW}新しいリポジトリ名を入力してください:${NC}"
            read NEW_REPO_NAME
            if [ -n "$NEW_REPO_NAME" ]; then
                REPO_NAME="$NEW_REPO_NAME"
                break
            else
                echo -e "${RED}リポジトリ名は空にできません。再度入力してください。${NC}"
            fi
        done
    elif [ -n "$USER_INPUT" ] && [ "$USER_INPUT" != "y" ] && [ "$USER_INPUT" != "Y" ]; then
        REPO_NAME="$USER_INPUT"
    fi
    
    # 公開/プライベートの選択
    echo -e "${YELLOW}リポジトリの公開設定を選択してください:${NC}"
    echo "1) 公開 (public)"
    echo "2) プライベート (private)"
    read -p "選択 (1/2): " VISIBILITY_CHOICE
    
    if [ "$VISIBILITY_CHOICE" = "2" ]; then
        VISIBILITY="private"
    else
        VISIBILITY="public"
    fi
    
    # GitHubリポジトリを作成
    create_github_repo "$REPO_NAME" "$VISIBILITY"
    REPO_CREATE_RESULT=$?
    
    if [ $REPO_CREATE_RESULT -eq 2 ]; then
        # ユーザーが既存リポジトリの使用をキャンセル
        echo -e "${YELLOW}処理を中断しました${NC}"
        exit 0
    elif [ $REPO_CREATE_RESULT -ne 0 ]; then
        echo -e "${RED}リポジトリの作成に失敗しました${NC}"
        exit 1
    fi
    
    # リモートリポジトリを追加
    # GitHub CLI からリモートURLを取得（より確実）
    if check_gh_available; then
        REMOTE_URL=$(gh repo view "$REPO_NAME" --json url -q .url 2>/dev/null)
        if [ -z "$REMOTE_URL" ]; then
            REMOTE_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
        fi
    else
        REMOTE_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
    fi
    if git remote get-url origin >/dev/null 2>&1; then
        CURRENT_REMOTE=$(git remote get-url origin)
        if [ "$CURRENT_REMOTE" != "$REMOTE_URL" ]; then
            echo -e "${YELLOW}既存のリモート 'origin' を更新中...${NC}"
            git remote set-url origin "$REMOTE_URL"
        fi
    else
        echo -e "${GREEN}リモート 'origin' を追加中...${NC}"
        git remote add origin "$REMOTE_URL"
    fi
    
    # ファイルをステージング
    echo -e "${GREEN}ファイルをステージング中...${NC}"
    git add .
    
    # 初回コミット
    if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
        echo -e "${YELLOW}初回コミットメッセージを入力してください (Enterでデフォルト使用):${NC}"
        read COMMIT_MSG
        if [ -z "$COMMIT_MSG" ]; then
            COMMIT_MSG="Initial commit"
        fi
        git commit -m "$COMMIT_MSG"
    fi
    
    # ブランチ名を確認
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
    if [ -z "$CURRENT_BRANCH" ]; then
        CURRENT_BRANCH="main"
        git branch -M main
    fi
    
    # プッシュ
    echo -e "${GREEN}GitHubにプッシュ中...${NC}"
    if git push -u origin "$CURRENT_BRANCH" 2>&1; then
        echo -e "${GREEN}✓ プッシュが完了しました！${NC}"
        echo -e "${GREEN}リポジトリURL: https://github.com/${GITHUB_USER}/${REPO_NAME}${NC}"
    else
        echo -e "${RED}✗ プッシュに失敗しました${NC}"
        exit 1
    fi
}

# 機能2: 强制推送
cmd_force_push() {
    if [ ! -d ".git" ]; then
        echo -e "${RED}エラー: これはGitリポジトリではありません${NC}"
        echo -e "${YELLOW}先に 'easygit init' を実行してください${NC}"
        exit 1
    fi
    
    # 現在の時刻とマシン情報を取得
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    HOSTNAME=$(hostname)
    if command -v uuidgen >/dev/null 2>&1; then
        MACHINE_ID=$(uuidgen | cut -d'-' -f1)
    elif command -v md5sum >/dev/null 2>&1; then
        MACHINE_ID=$(hostname | md5sum | cut -d' ' -f1 | cut -c1-8)
    elif command -v md5 >/dev/null 2>&1; then
        MACHINE_ID=$(hostname | md5 | cut -c1-8)
    else
        MACHINE_ID=$(echo "$HOSTNAME" | sha256sum 2>/dev/null | cut -d' ' -f1 | cut -c1-8 || echo "unknown")
    fi
    
    COMMIT_MSG="Force push: $TIMESTAMP @ $HOSTNAME [$MACHINE_ID]"
    
    echo -e "${YELLOW}强制推送を実行します${NC}"
    echo -e "${CYAN}提交信息: $COMMIT_MSG${NC}"
    echo -e "${RED}警告: 这将强制覆盖远程仓库！${NC}"
    echo -e "${YELLOW}続行しますか？ (y/n):${NC}"
    read CONFIRM
    
    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
        echo -e "${YELLOW}操作がキャンセルされました${NC}"
        exit 0
    fi
    
    # すべての変更をステージング
    echo -e "${GREEN}変更をステージング中...${NC}"
    git add -A
    
    # コミット（変更がある場合）
    if ! git diff --cached --quiet || ! git diff --quiet; then
        git commit -m "$COMMIT_MSG"
    fi
    
    # 强制推送
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
    echo -e "${GREEN}强制推送中...${NC}"
    if git push --force origin "$CURRENT_BRANCH" 2>&1; then
        echo -e "${GREEN}✓ 强制推送が完了しました！${NC}"
    else
        echo -e "${RED}✗ 强制推送に失敗しました${NC}"
        exit 1
    fi
}

# 機能3: 强制恢复（リモートでローカルを上書き）
cmd_force_pull() {
    if [ ! -d ".git" ]; then
        echo -e "${RED}エラー: これはGitリポジトリではありません${NC}"
        echo -e "${YELLOW}先に 'easygit init' を実行してください${NC}"
        exit 1
    fi
    
    echo -e "${RED}警告: これによりローカルの変更がすべて失われます！${NC}"
    echo -e "${YELLOW}続行しますか？ (y/n):${NC}"
    read CONFIRM
    
    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
        echo -e "${YELLOW}操作がキャンセルされました${NC}"
        exit 0
    fi
    
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
    
    # リモートから最新情報を取得
    echo -e "${GREEN}リモート情報を取得中...${NC}"
    git fetch origin
    
    # ローカルの変更をすべて破棄
    echo -e "${GREEN}ローカルの変更を破棄中...${NC}"
    git reset --hard origin/"$CURRENT_BRANCH" 2>/dev/null || git reset --hard origin/main 2>/dev/null
    
    # 追跡されていないファイルを削除
    echo -e "${GREEN}追跡されていないファイルを削除中...${NC}"
    git clean -fd
    
    echo -e "${GREEN}✓ 强制恢复が完了しました！${NC}"
    echo -e "${CYAN}ローカルはリモートと完全に同期されました${NC}"
}

# 機能4: 普通推送
cmd_push() {
    if [ ! -d ".git" ]; then
        echo -e "${RED}エラー: これはGitリポジトリではありません${NC}"
        echo -e "${YELLOW}先に 'easygit init' を実行してください${NC}"
        exit 1
    fi
    
    # リモートが設定されているか確認
    if ! git remote get-url origin >/dev/null 2>&1; then
        echo -e "${RED}エラー: リモートリポジトリが設定されていません${NC}"
        echo -e "${YELLOW}先に 'easygit init' または 'easygit set-remote' を実行してください${NC}"
        exit 1
    fi
    
    # 変更があるか確認
    if git diff --quiet && git diff --cached --quiet && [ -z "$(git status --porcelain)" ]; then
        echo -e "${YELLOW}変更がありません${NC}"
    else
        # 変更をステージング
        echo -e "${GREEN}変更をステージング中...${NC}"
        git add -A
        
        # コミットメッセージを入力
        echo -e "${YELLOW}コミットメッセージを入力してください:${NC}"
        read COMMIT_MSG
        if [ -z "$COMMIT_MSG" ]; then
            COMMIT_MSG="Update: $(date '+%Y-%m-%d %H:%M:%S')"
        fi
        
        # コミット
        echo -e "${GREEN}コミット中...${NC}"
        git commit -m "$COMMIT_MSG"
    fi
    
    # 現在のブランチを取得
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
    if [ -z "$CURRENT_BRANCH" ]; then
        CURRENT_BRANCH="main"
        git branch -M main
    fi
    
    # プッシュ
    echo -e "${GREEN}リモートにプッシュ中...${NC}"
    if git push -u origin "$CURRENT_BRANCH" 2>&1; then
        echo -e "${GREEN}✓ プッシュが完了しました！${NC}"
    else
        echo -e "${RED}✗ プッシュに失敗しました${NC}"
        echo -e "${YELLOW}ヒント: リモートに新しい変更がある場合は 'easygit pull' を先に実行してください${NC}"
        exit 1
    fi
}

# 機能5: 普通拉取
cmd_pull() {
    if [ ! -d ".git" ]; then
        echo -e "${RED}エラー: これはGitリポジトリではありません${NC}"
        echo -e "${YELLOW}先に 'easygit init' を実行してください${NC}"
        exit 1
    fi
    
    # リモートが設定されているか確認
    if ! git remote get-url origin >/dev/null 2>&1; then
        echo -e "${RED}エラー: リモートリポジトリが設定されていません${NC}"
        echo -e "${YELLOW}先に 'easygit init' または 'easygit set-remote' を実行してください${NC}"
        exit 1
    fi
    
    # 現在のブランチを取得
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
    if [ -z "$CURRENT_BRANCH" ]; then
        CURRENT_BRANCH="main"
        git branch -M main
    fi
    
    # ローカルに未コミットの変更があるか確認
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo -e "${YELLOW}警告: ローカルに未コミットの変更があります${NC}"
        echo -e "${YELLOW}続行しますか？ (y/n):${NC}"
        read CONFIRM
        if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
            echo -e "${YELLOW}操作がキャンセルされました${NC}"
            exit 0
        fi
    fi
    
    # フェッチ
    echo -e "${GREEN}リモート情報を取得中...${NC}"
    git fetch origin
    
    # プル
    echo -e "${GREEN}リモートから変更を取得中...${NC}"
    if git pull origin "$CURRENT_BRANCH" 2>&1; then
        echo -e "${GREEN}✓ プルが完了しました！${NC}"
    else
        echo -e "${RED}✗ プルに失敗しました${NC}"
        echo -e "${YELLOW}ヒント: 競合がある場合は解決してから再試行してください${NC}"
        exit 1
    fi
}

# 機能6: リポジトリ情報を表示
cmd_info() {
    if [ ! -d ".git" ]; then
        echo -e "${RED}これはGitリポジトリではありません${NC}"
        echo -e "${YELLOW}先に 'easygit init' を実行してリポジトリを初期化してください${NC}"
        exit 1
    fi
    
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}Git リポジトリ情報${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    
    # 現在のブランチ
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
    echo -e "${GREEN}ブランチ:${NC} $CURRENT_BRANCH"
    
    # リモート情報
    if git remote get-url origin >/dev/null 2>&1; then
        REMOTE_URL=$(git remote get-url origin)
        echo -e "${GREEN}リモート:${NC} $REMOTE_URL"
        
        # リモートブランチ情報を取得
        git fetch origin --quiet 2>/dev/null
        REMOTE_BRANCH=$(git branch -r | grep "origin/$CURRENT_BRANCH" | head -1 | sed 's|origin/||' | xargs)
        if [ -n "$REMOTE_BRANCH" ]; then
            LOCAL_COMMIT=$(git rev-parse HEAD 2>/dev/null | cut -c1-7)
            REMOTE_COMMIT=$(git rev-parse "origin/$CURRENT_BRANCH" 2>/dev/null | cut -c1-7)
            echo -e "${GREEN}ローカルコミット:${NC} $LOCAL_COMMIT"
            echo -e "${GREEN}リモートコミット:${NC} $REMOTE_COMMIT"
            
            # ローカルとリモートの差分を確認
            if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
                BEHIND=$(git rev-list --count HEAD..origin/"$CURRENT_BRANCH" 2>/dev/null || echo "0")
                AHEAD=$(git rev-list --count origin/"$CURRENT_BRANCH"..HEAD 2>/dev/null || echo "0")
                if [ "$BEHIND" -gt 0 ]; then
                    echo -e "${YELLOW}状態:${NC} リモートより $BEHIND コミット遅れています"
                fi
                if [ "$AHEAD" -gt 0 ]; then
                    echo -e "${YELLOW}状態:${NC} リモートより $AHEAD コミット先に進んでいます"
                fi
            else
                echo -e "${GREEN}状態:${NC} リモートと同期されています"
            fi
        fi
    else
        echo -e "${YELLOW}リモート:${NC} 設定されていません"
    fi
    
    # ローカルの変更状態
    echo ""
    echo -e "${CYAN}ローカルの変更:${NC}"
    if ! git diff --quiet 2>/dev/null; then
        CHANGED_FILES=$(git diff --name-only | wc -l | xargs)
        echo -e "${YELLOW}  変更されたファイル: $CHANGED_FILES${NC}"
        git diff --stat | head -10
        if [ "$CHANGED_FILES" -gt 10 ]; then
            echo "  ... (他 $(($CHANGED_FILES - 10)) ファイル)"
        fi
    else
        echo -e "${GREEN}  変更はありません${NC}"
    fi
    
    # ステージングされた変更
    if ! git diff --cached --quiet 2>/dev/null; then
        STAGED_FILES=$(git diff --cached --name-only | wc -l | xargs)
        echo -e "${YELLOW}  ステージングされたファイル: $STAGED_FILES${NC}"
    fi
    
    # 追跡されていないファイル
    UNTRACKED=$(git ls-files --others --exclude-standard | wc -l | xargs)
    if [ "$UNTRACKED" -gt 0 ]; then
        echo -e "${YELLOW}  追跡されていないファイル: $UNTRACKED${NC}"
    fi
    
    # 最新のコミット情報
    echo ""
    echo -e "${CYAN}最新のコミット:${NC}"
    if git rev-parse --verify HEAD >/dev/null 2>&1; then
        git log -1 --pretty=format:"  ${GREEN}%h${NC} - ${BLUE}%an${NC} - ${YELLOW}%ar${NC}%n  %s" 2>/dev/null
    else
        echo -e "${YELLOW}  まだコミットがありません${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}========================================${NC}"
}

# 機能5: 重新指定远程仓库
cmd_set_remote() {
    if [ ! -d ".git" ]; then
        echo -e "${RED}エラー: これはGitリポジトリではありません${NC}"
        echo -e "${YELLOW}先に 'easygit init' を実行してください${NC}"
        exit 1
    fi
    
    # 检查是否提供了 URL 参数
    NEW_REMOTE_URL="$1"
    NON_INTERACTIVE=false
    
    if [ -n "$NEW_REMOTE_URL" ]; then
        # 如果提供了 URL 参数，使用非交互模式
        NON_INTERACTIVE=true
    fi
    
    # 检查当前远程仓库
    if git remote get-url origin >/dev/null 2>&1; then
        CURRENT_REMOTE=$(git remote get-url origin)
        echo -e "${CYAN}現在のリモートリポジトリ:${NC}"
        echo -e "${GREEN}  origin: $CURRENT_REMOTE${NC}"
        echo ""
    else
        echo -e "${YELLOW}現在リモートリポジトリが設定されていません${NC}"
        echo ""
    fi
    
    # 如果没有提供 URL 参数，则交互式输入
    if [ -z "$NEW_REMOTE_URL" ]; then
        echo -e "${YELLOW}新しいリモートリポジトリのURLを入力してください:${NC}"
        echo -e "${CYAN}例: https://github.com/username/repo.git${NC}"
        echo -e "${CYAN}    または: git@github.com:username/repo.git${NC}"
        read -p "URL: " NEW_REMOTE_URL
    else
        echo -e "${CYAN}新しいリモートリポジトリURL: ${GREEN}$NEW_REMOTE_URL${NC}"
        echo ""
    fi
    
    if [ -z "$NEW_REMOTE_URL" ]; then
        echo -e "${RED}エラー: URLが空です${NC}"
        exit 1
    fi
    
    # 验证 URL 格式
    if ! echo "$NEW_REMOTE_URL" | grep -qE '^(https?://|git@)'; then
        if [ "$NON_INTERACTIVE" = true ]; then
            echo -e "${YELLOW}⚠️  URL形式が正しくない可能性がありますが、続行します${NC}"
        else
            echo -e "${YELLOW}⚠️  URL形式が正しくない可能性があります${NC}"
            echo -e "${YELLOW}続行しますか？ (y/n):${NC}"
            read CONFIRM
            if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
                echo -e "${YELLOW}操作がキャンセルされました${NC}"
                exit 0
            fi
        fi
    fi
    
    # 设置或更新远程仓库
    if git remote get-url origin >/dev/null 2>&1; then
        if [ "$NON_INTERACTIVE" = false ]; then
            echo -e "${YELLOW}既存の 'origin' を更新しますか？ (y/n):${NC}"
            read CONFIRM
            if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
                echo -e "${YELLOW}操作がキャンセルされました${NC}"
                exit 0
            fi
        fi
        git remote set-url origin "$NEW_REMOTE_URL"
        echo -e "${GREEN}✓ リモートリポジトリ 'origin' を更新しました${NC}"
    else
        git remote add origin "$NEW_REMOTE_URL"
        echo -e "${GREEN}✓ リモートリポジトリ 'origin' を追加しました${NC}"
    fi
    
    # 验证远程仓库
    VERIFY_URL=$(git remote get-url origin)
    echo -e "${CYAN}確認: ${NC}$VERIFY_URL"
    
    # 询问是否要推送
    if [ "$NON_INTERACTIVE" = false ]; then
        echo ""
        echo -e "${YELLOW}現在の内容を新しいリモートリポジトリにプッシュしますか？ (y/n):${NC}"
        read PUSH_CHOICE
    else
        # 非交互模式下，不自动推送
        PUSH_CHOICE="n"
    fi
    
    if [ "$PUSH_CHOICE" = "y" ] || [ "$PUSH_CHOICE" = "Y" ]; then
        CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
        if [ -z "$CURRENT_BRANCH" ]; then
            CURRENT_BRANCH="main"
            git branch -M main
        fi
        
        echo -e "${GREEN}リモートリポジトリにプッシュ中...${NC}"
        if git push -u origin "$CURRENT_BRANCH" 2>&1; then
            echo -e "${GREEN}✓ プッシュが完了しました！${NC}"
        else
            echo -e "${RED}✗ プッシュに失敗しました${NC}"
            echo -e "${YELLOW}ヒント: リモートリポジトリが存在しない、または権限がない可能性があります${NC}"
            exit 1
        fi
    else
        if [ "$NON_INTERACTIVE" = false ]; then
            echo -e "${CYAN}プッシュをスキップしました${NC}"
            echo -e "${YELLOW}後で 'git push -u origin <branch-name>' を実行してください${NC}"
        fi
    fi
}

# メイン処理
case "${1:-}" in
    init)
        cmd_init
        ;;
    set-remote)
        cmd_set_remote "$2"
        ;;
    push)
        cmd_push
        ;;
    pull)
        cmd_pull
        ;;
    force-push)
        cmd_force_push
        ;;
    force-pull)
        cmd_force_pull
        ;;
    info)
        cmd_info
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        echo -e "${RED}エラー: 不明なコマンド '$1'${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac

