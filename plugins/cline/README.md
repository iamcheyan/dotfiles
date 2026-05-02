# Cline CLI Plugin

[Cline](https://docs.cline.bot/cline-cli/cli-reference) - Autonomous coding agent CLI for the terminal.

## Install

```bash
./install.sh
```

The script will:
1. Install nvm (if not present)
2. Create an isolated Node.js environment via `nvm alias cline`
3. Install the `cline` npm package globally in that environment
4. Add shell integration (zsh/bash) so `cline` is available everywhere

## Usage

```bash
cline                         # interactive mode
cline "your prompt"           # direct task
cline auth                    # configure AI provider
cline --help                  # show all options
```

## Uninstall

```bash
./uninstall.sh
```
