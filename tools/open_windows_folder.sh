#!/usr/bin/env bash
# WSLからWindowsのexplorer.exeでフォルダを開くスクリプト

set -eo pipefail

# 引数チェック
if [[ $# -eq 0 ]]; then
  # 引数がない場合は現在のディレクトリをWindowsパスに変換
  folder_path=$(wslpath -w "$PWD")
else
  # すべての引数をスペースで結合して1つのパスとして扱う
  # クォートなしで実行された場合、複数の引数が渡される可能性があるため
  IFS=' '
  folder_path="$*"
fi

# explorer.exeでフォルダを開く
echo "フォルダを開いています: ${folder_path}"
explorer.exe "${folder_path}"

