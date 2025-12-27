#!/usr/bin/env bash

set -euo pipefail

search_root="$(pwd)"

echo "探索ディレクトリ: ${search_root}"
echo "Zone.Identifier ファイルを検索しています..."

# :Zone.Identifier と zone.identifier の両方のパターンを検索
mapfile -d '' zone_files < <(find "${search_root}" -type f \( -name '*:Zone.Identifier' -o -name 'zone.identifier' \) -print0) || true

if [[ "${#zone_files[@]}" -eq 0 ]]; then
  echo "対象ファイルは見つかりませんでした。"
  exit 0
fi

echo "以下のファイルが見つかりました:"
for file in "${zone_files[@]}"; do
  printf ' - %s\n' "${file}"
done

read -r -p "これらのファイルを削除しますか？ [y/N]: " answer

case "${answer}" in
  [yY])
    ;;
  *)
    echo "削除をキャンセルしました。"
    exit 0
    ;;
esac

delete_error=0
for file in "${zone_files[@]}"; do
  if rm -f -- "${file}"; then
    echo "削除しました: ${file}"
  else
    echo "削除できませんでした: ${file}" >&2
    delete_error=1
  fi
done

if [[ "${delete_error}" -ne 0 ]]; then
  echo "一部のファイルを削除できませんでした。" >&2
  exit 1
fi

echo "すべての Zone.Identifier ファイルを削除しました。"

