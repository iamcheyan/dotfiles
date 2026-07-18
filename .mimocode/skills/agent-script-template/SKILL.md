---
name: agent-script-template
description: Create a new AI coding agent launcher script following the established pattern (check binary → install → exec passthrough)
---

# Agent Script Template

Create a new AI coding agent launcher script that follows the established pattern in `~/dotfiles/agent/`.

## Template Structure

```bash
#!/usr/bin/env bash
# Usage:
#   <name>                         # Run <name> CLI (default: last session)
#   <name> -f                      # Force reinstall <name>
#
# ── <Name> CLI Reference ──────────────────────────────────────────────────────
#
# Binary: <binary-name> (installed to ~/.local/bin/)
#
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

# Check for -f flag (force reinstall)
FORCE_REINSTALL=false
for arg in "$@"; do
  if [ "$arg" = "-f" ]; then
    FORCE_REINSTALL=true
    break
  fi
done

if $FORCE_REINSTALL || ! command -v <binary-name> &>/dev/null; then
  echo "<binary-name> not found, installing..."
  curl -fsSL <install-url> | bash
  export PATH="$HOME/.local/bin:$PATH"
fi

if [ $# -eq 0 ]; then
  exec <binary-name>
else
  exec <binary-name> "$@"
fi
```

## Steps

1. **Determine variables**:
   - `<name>`: Script name (e.g., `kiro`, `copilot`)
   - `<binary-name>`: Binary name after install (e.g., `kiro-cli`, `copilot`)
   - `<install-url>`: Installation URL (e.g., `https://cli.kiro.dev/install`)
   - `<Name>`: Display name for comments (e.g., `Kiro`, `Copilot`)

2. **Create script** at `~/dotfiles/agent/<name>.sh` using the template

3. **Make executable**: `chmod +x ~/dotfiles/agent/<name>.sh`

4. **Add alias** to `~/dotfiles/aliases.conf`:
   ```bash
   alias <name>="$HOME/dotfiles/agent/<name>.sh"
   ```

5. **Apply changes**: Run `chezmoi apply` to sync

## Validation

- Script must be executable
- Script must pass `bash -n` syntax check
- Alias must be added to aliases.conf
- `chezmoi apply` must succeed

## Examples

See existing scripts:
- `~/dotfiles/agent/mimo.sh` - MiMo Code
- `~/dotfiles/agent/kiro.sh` - Kiro CLI
- `~/dotfiles/agent/copilot.sh` - GitHub Copilot
