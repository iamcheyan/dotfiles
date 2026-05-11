#!/usr/bin/env python3
"""
Translation Tool TUI: Chinese-Japanese Bidirectional Translation using Amazon Bedrock kimi-k2.5
- Chinese input -> Japanese output
- Japanese input -> Chinese output
- Multi-line input support with continuous translation

Usage:
  python translate.py              # Start interactive TUI
  python translate.py -m <model>   # Use specified model

In TUI:
  - Type your text
  - Press Enter to submit and translate
  - Press Alt+Enter for new line
  - Type 'quit' or 'exit' to exit
"""

import boto3
import json
import sys
import re
import os

# ANSI color codes
YELLOW = '\033[33m'  # Dark yellow/orange
RESET = '\033[0m'


def detect_language(text):
    """
    Detect text language: Chinese, Japanese, or Unknown
    """
    # Check for Japanese hiragana/katakana
    has_hiragana = bool(re.search(r'[\u3040-\u309f]', text))
    has_katakana = bool(re.search(r'[\u30a0-\u30ff]', text))

    # Check for CJK characters
    has_cjk = bool(re.search(r'[\u4e00-\u9fff]', text))

    if has_hiragana or has_katakana:
        return "ja"
    elif has_cjk:
        return "zh"
    else:
        return "unknown"


def translate_with_bedrock(text, source_lang, model_id='kimi-k2.5'):
    """
    Translate using Amazon Bedrock model
    Default: kimi-k2.5, fallback to other models if fails
    """
    region = os.environ.get('AWS_REGION', 'ap-northeast-1')

    bedrock_runtime = boto3.client(
        service_name='bedrock-runtime',
        region_name=region
    )

    if source_lang == "zh":
        instruction = "请把以下中文翻译成日语。注意：我们是一家互联网公司，通常使用商务日语和IT专业词汇，避免使用过于口语化或日常生活用语。只输出翻译结果，不要解释："
    else:
        instruction = "请把以下日语翻译成中文。注意：我们是一家互联网公司，原文可能是商务日语或IT专业术语，请使用相应的中文商务/IT用语翻译，避免字面直译。只输出翻译结果，不要解释："

    prompt = f"{instruction}\n\n{text}"

    models_to_try = [model_id, 'anthropic.claude-3-sonnet-20240229-v1:0', 'anthropic.claude-3-haiku-20240307-v1:0']

    for model in models_to_try:
        try:
            if 'anthropic' in model.lower():
                body = json.dumps({
                    "anthropic_version": "bedrock-2023-05-31",
                    "messages": [
                        {
                            "role": "user",
                            "content": prompt
                        }
                    ],
                    "max_tokens": 4096,
                    "temperature": 0.3
                })
            else:
                body = json.dumps({
                    "messages": [
                        {
                            "role": "user",
                            "content": prompt
                        }
                    ],
                    "max_tokens": 4096,
                    "temperature": 0.3,
                    "top_p": 0.9
                })

            response = bedrock_runtime.invoke_model(
                modelId=model,
                body=body
            )

            response_body = json.loads(response.get('body').read())

            if 'content' in response_body and len(response_body['content']) > 0:
                if isinstance(response_body['content'], list):
                    translation = response_body['content'][0].get('text', '').strip()
                else:
                    translation = response_body['content'].strip()
                return translation
            elif 'completion' in response_body:
                return response_body['completion'].strip()
            elif 'output' in response_body:
                return response_body['output'].strip()
            else:
                return str(response_body)

        except Exception as e:
            error_msg = str(e)
            if 'invalid model identifier' in error_msg.lower() or 'validationexception' in error_msg.lower():
                continue
            return f"Translation error: {error_msg}"

    return "Translation error: No available model found"


def get_japanese_with_furigana(text, model_id='kimi-k2.5'):
    """
    Get Japanese text with furigana reading
    """
    region = os.environ.get('AWS_REGION', 'ap-northeast-1')

    bedrock_runtime = boto3.client(
        service_name='bedrock-runtime',
        region_name=region
    )

    instruction = "请为以下日文文本标注假名读音，格式为：在汉字后面用括号标注假名。例如：「今日（きょう）」「良（い）い天気（てんき）」。只输标注后的文本，不要解释："
    prompt = f"{instruction}\n\n{text}"

    models_to_try = [model_id, 'anthropic.claude-3-sonnet-20240229-v1:0', 'anthropic.claude-3-haiku-20240307-v1:0']

    for model in models_to_try:
        try:
            if 'anthropic' in model.lower():
                body = json.dumps({
                    "anthropic_version": "bedrock-2023-05-31",
                    "messages": [
                        {
                            "role": "user",
                            "content": prompt
                        }
                    ],
                    "max_tokens": 4096,
                    "temperature": 0.3
                })
            else:
                body = json.dumps({
                    "messages": [
                        {
                            "role": "user",
                            "content": prompt
                        }
                    ],
                    "max_tokens": 4096,
                    "temperature": 0.3,
                    "top_p": 0.9
                })

            response = bedrock_runtime.invoke_model(
                modelId=model,
                body=body
            )

            response_body = json.loads(response.get('body').read())

            if 'content' in response_body and len(response_body['content']) > 0:
                if isinstance(response_body['content'], list):
                    furigana = response_body['content'][0].get('text', '').strip()
                else:
                    furigana = response_body['content'].strip()
                return furigana
            elif 'completion' in response_body:
                return response_body['completion'].strip()
            elif 'output' in response_body:
                return response_body['output'].strip()
            else:
                return str(response_body)

        except Exception as e:
            error_msg = str(e)
            if 'invalid model identifier' in error_msg.lower() or 'validationexception' in error_msg.lower():
                continue
            return None

    return None


def get_input_with_prompt_toolkit():
    """
    Get input using prompt_toolkit.
    - Enter: submit
    - Alt+Enter: new line
    """
    from prompt_toolkit import PromptSession
    from prompt_toolkit.key_binding import KeyBindings
    from prompt_toolkit.enums import EditingMode
    from prompt_toolkit.filters import Condition

    bindings = KeyBindings()

    @bindings.add('enter', eager=True)
    def _(event):
        """Enter submits the text"""
        event.app.exit(result=event.app.current_buffer.text)

    @bindings.add('escape', 'enter')
    def _(event):
        """Alt+Enter (Escape+Enter) inserts a newline"""
        event.app.current_buffer.insert_text('\n')

    @bindings.add('c-c', eager=True)
    def _(event):
        """Ctrl+C cancels"""
        event.app.exit(result=None)

    @bindings.add('c-d', eager=True)
    def _(event):
        """Ctrl+D exits if empty"""
        if event.app.current_buffer.text == "":
            event.app.exit(result=None)
        else:
            # Insert newline otherwise
            event.app.current_buffer.insert_text('\n')

    session = PromptSession(
        key_bindings=bindings,
        editing_mode=EditingMode.EMACS,
        multiline=True,
        enable_history_search=True,
    )

    try:
        return session.prompt("> ")
    except (KeyboardInterrupt, EOFError):
        return None


def print_banner():
    """Print welcome banner"""
    print("=" * 60)
    print("  Chinese-Japanese Translation TUI")
    print("  Chinese -> Japanese | Japanese -> Chinese")
    print("=" * 60)
    print()
    print("Usage:")
    print("  - Type text to translate")
    print("  - Press Enter to submit and translate")
    print("  - Press Alt+Enter for new line")
    print("  - Type 'quit' or 'exit' to exit")
    print()
    print("-" * 60)


def interactive_mode(model_id='kimi-k2.5'):
    """
    Interactive translation mode
    """
    print_banner()

    while True:
        try:
            text = get_input_with_prompt_toolkit()
        except Exception as e:
            print(f"\nInput error: {e}")
            continue

        if text is None:
            print("\nGoodbye!")
            break

        text = text.strip()

        if not text:
            continue

        if text.lower() in ('quit', 'exit', 'q'):
            print("\nGoodbye!")
            break

        # Detect language
        source_lang = detect_language(text)

        if source_lang == "unknown":
            print("[Error] Cannot detect language, please enter Chinese or Japanese")
            continue

        # Translate
        result = translate_with_bedrock(text, source_lang, model_id)

        # Output result with yellow color
        if source_lang == "zh":
            # Chinese to Japanese: show original result and furigana version
            print(f"{YELLOW}{result}{RESET}")
            # Get furigana version
            furigana = get_japanese_with_furigana(result, model_id)
            if furigana:
                print(f"{YELLOW}{furigana}{RESET}")
        else:
            # Japanese to Chinese: just show the result
            print(f"{YELLOW}{result}{RESET}")
        print()


def command_line_mode(text, model_id='kimi-k2.5'):
    """
    Command line mode (single-line translation)
    """
    source_lang = detect_language(text)

    if source_lang == "unknown":
        print("Cannot detect language, please enter Chinese or Japanese")
        sys.exit(1)

    result = translate_with_bedrock(text, source_lang, model_id)
    print(result)


def main():
    if len(sys.argv) < 2:
        # No arguments, enter interactive TUI mode
        interactive_mode()
    else:
        # Check for -m parameter to specify model
        model_id = 'kimi-k2.5'
        text_start = 1

        if sys.argv[1] == '-m' and len(sys.argv) >= 3:
            model_id = sys.argv[2]
            if len(sys.argv) >= 4:
                text_start = 3
                text = ' '.join(sys.argv[text_start:])
                command_line_mode(text, model_id)
            else:
                # Only -m parameter, enter interactive mode
                interactive_mode(model_id)
        else:
            # Command line mode with text argument
            text = ' '.join(sys.argv[text_start:])
            command_line_mode(text, model_id)


if __name__ == "__main__":
    main()
