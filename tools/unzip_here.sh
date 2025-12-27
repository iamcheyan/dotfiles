#!/usr/bin/env bash
# 実行した場所を基準に、すべての .zip を再帰的に展開する

set -euo pipefail

if ! command -v unzip >/dev/null 2>&1; then
  echo "Error: unzip is not installed." >&2
  exit 1
fi

BASE_DIR="$(pwd)"

find "$BASE_DIR" -type f -name '*.zip' -print0 | while IFS= read -r -d '' zip_file; do
  dir=$(dirname "$zip_file")
  echo "Extracting: $zip_file -> $dir"
  unzip -n -d "$dir" "$zip_file"
done
#!/usr/bin/env bash
# 実行したカレントディレクトリ以下の .zip をすべて再帰的に展開する

set -euo pipefail

# unzip の存在を確認
if ! command -v unzip >/dev/null 2>&1; then
  echo "Error: unzip is not installed." >&2
  exit 1
fi

# 現在のディレクトリを基準に検索
BASE_DIR="$(pwd)"

find "$BASE_DIR" -type f -name '*.zip' -print0 | while IFS= read -r -d '' zip_file; do
  dir=$(dirname "$zip_file")
  echo "Extracting: $zip_file -> $dir"
  unzip -n -d "$dir" "$zip_file"
done
#!/usr/bin/env bash
# カレントディレクトリ以下の .zip を再帰的に検索し、
# 各 zip と同名のディレクトリを作成してその中に展開する

set -euo pipefail

# unzip チェック
if ! command -v unzip >/dev/null 2>&1; then
  echo "Error: unzip is not installed." >&2
  exit 1
fi

BASE_DIR="$(pwd)"

find "$BASE_DIR" -type f -name '*.zip' -print0 | while IFS= read -r -d '' zip_file; do
  # zip のあるディレクトリ
  parent_dir=$(dirname "$zip_file")

  # zip のファイル名（拡張子なし）
  zip_name=$(basename "$zip_file" .zip)

  # 新しい展開先ディレクトリ
  target_dir="$parent_dir/$zip_name"

  # ディレクトリを作成
  mkdir -p "$target_dir"

  echo "Extracting: $zip_file -> $target_dir"

  # 上書きしない (-n)
  unzip -n -d "$target_dir" "$zip_file"
done
