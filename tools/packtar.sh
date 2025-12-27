#!/usr/bin/env bash
# 現在のディレクトリをtar.gzでパッケージ化し、親ディレクトリに配置する
# 使用方法: pack_tar.sh <filename>

set -euo pipefail

# 引数チェック
if [ $# -eq 0 ]; then
    echo "Error: ファイル名を指定してください" >&2
    echo "使用方法: $0 <filename>" >&2
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

# ディレクトリ変更とアーカイブパスを最後に追加
TAR_ARGS+=(
    -C "${CURRENT_DIR}" .
)

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

