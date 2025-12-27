#!/usr/bin/env bash
# 日本語を平假名、片假名、ローマ字に変換するスクリプト
# 使用方法:
#   jp_convert.sh "日本語のテキスト"
#   echo "日本語のテキスト" | jp_convert.sh
#   jp_convert.sh  # 対話モード

set -euo pipefail

# Pythonとpykakasiの存在確認
if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 is not installed." >&2
    exit 1
fi

# pykakasiがインストールされているか確認
if ! python3 -c "import pykakasi" >/dev/null 2>&1; then
    echo "Error: pykakasi is not installed." >&2
    echo "Please install it with: pip install pykakasi" >&2
    exit 1
fi

# 入力テキストを取得
if [ $# -gt 0 ]; then
    # 引数から取得
    INPUT_TEXT="$*"
elif [ ! -t 0 ]; then
    # パイプから取得
    INPUT_TEXT=$(cat)
else
    # 対話モード
    echo "日本語のテキストを入力してください（Enterで確定）:"
    read -r INPUT_TEXT
fi

# 空の場合はエラー
if [ -z "$INPUT_TEXT" ]; then
    echo "Error: テキストが入力されていません" >&2
    exit 1
fi

# Pythonスクリプトで変換を実行
python3 - "$INPUT_TEXT" << 'EOF'
import sys
import pykakasi

def convert_japanese(text):
    kks = pykakasi.kakasi()
    result = kks.convert(text)
    
    hiragana = ""
    katakana = ""
    romaji = ""
    
    for item in result:
        hiragana += item.get('hira', item.get('orig', ''))
        katakana += item.get('kana', item.get('orig', ''))
        romaji += item.get('hepburn', item.get('orig', ''))
    
    return hiragana, katakana, romaji

if __name__ == "__main__":
    if len(sys.argv) > 1:
        input_text = " ".join(sys.argv[1:])
    else:
        input_text = sys.stdin.read().strip()
    
    if not input_text:
        print("Error: テキストが入力されていません", file=sys.stderr)
        sys.exit(1)
    
    hira, kata, roma = convert_japanese(input_text)
    
    print(f"  {hira}")
    print(f"  {kata}")
    print(f"  {roma}")
EOF

