#!/usr/bin/env bash
# Usage:
#   oc                              # Continue last session (skip permissions)
#   oc <provider>                   # Run with provider from opencode.json
#   oc <provider> <model>           # Run with specific model
#   oc -s, --select                 # Interactive model selection
#   oc -m, --model <provider/model> # Override model directly
#   oc -p, --print <prompt>         # Non-interactive: answer and exit
#   oc -v, --version                # Show version
#   oc -c                           # Continue last session
#   oc --dangerously-skip-permissions  # Auto-approve all permissions
#
# Examples:
#   oc                              # Continue last session
#   oc zhipu                        # Use zhipu provider (glm-4-flash, free)
#   oc deepseek                     # Use deepseek provider
#   oc -m mimo/mimo-v2.5-pro        # Use specific model
#   oc -p "explain this function"   # Non-interactive question
#   oc -s                           # Pick model from interactive list
#   oc -f                           # Force reinstall opencode
#
# ── OpenCode CLI Reference ───────────────────────────────────────────────────
#
# Session:
#   -c, --continue                    Continue the last session
#   -s, --session <id>                Session id to continue
#   --fork                            Fork the session when continuing
#
# Model:
#   -m, --model <provider/model>      Model to use
#   --agent <name>                    Agent to use
#
# Prompt:
#   --prompt <text>                   Prompt to use
#   prompt..                          Positional prompt args (run mode)
#
# Permissions & Sandbox:
#   --dangerously-skip-permissions    Auto-approve permissions not explicitly denied
#
# Input / Output:
#   -f, --file <path>                 Attach file(s) to message (run mode)
#   --format <fmt>                    default (formatted) or json (raw events)
#   --thinking                        Show thinking blocks
#   --variant <level>                 Model variant / reasoning effort
#   --share                           Share the session
#   --title <text>                    Title for the session
#
# Remote & Server:
#   --attach <url>                    Attach to running opencode server
#   --dir <path>                      Directory to run in (path on remote if attaching)
#   --port <number>                   Port for local server
#   -p, --password <pass>             Basic auth password
#   -u, --username <user>             Basic auth username
#
# TUI:
#   --replay                          Replay interactive session history on resume
#   --replay-limit <n>                Cap visible replay to newest N messages
#   -i, --interactive                 Direct interactive split-footer mode (run mode)
#
# Server & Web:
#   serve                             Start headless server
#   web                               Start server and open web interface
#   attach <url>                      Attach to running server
#
# Subcommands:
#   run [message..]                   Run with a message (non-TUI)
#   models [provider]                 List available models
#   providers / auth                  Manage providers and credentials
#   session                           Manage sessions
#   agent                             Manage agents
#   mcp                               Manage MCP servers
#   plugin <module>                   Install plugin
#   upgrade [target]                  Upgrade to latest or specific version
#   uninstall                         Uninstall and remove all files
#   export [sessionID]                Export session data as JSON
#   import <file>                     Import session data
#   github                            Manage GitHub agent
#   pr <number>                       Fetch PR branch and run opencode
#   stats                             Show token usage and cost
#   completion                        Generate shell completions
#   debug                             Debugging and troubleshooting
#   db                                Database tools
#
# Global Options:
#   -v, --version                     Show version
#   -h, --help                        Show help
#   --pure                            Run without external plugins
#   --print-logs                      Print logs to stderr
#   --log-level <level>               DEBUG | INFO | WARN | ERROR
#   --port <number>                   Port to listen on
#   --hostname <host>                 Hostname to listen on
#   --mdns                            Enable mDNS service discovery
#   --mdns-domain <domain>            Custom mDNS domain (default: opencode.local)
#   --cors <domains...>               Additional CORS domains
#
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

HAS_ARGS=$#

# Check for -f flag (force reinstall)
FORCE_REINSTALL=false
for arg in "$@"; do
  if [ "$arg" = "-f" ]; then
    FORCE_REINSTALL=true
    break
  fi
done

# ── Install check ─────────────────────────────────────────────────────────────
if $FORCE_REINSTALL || ! command -v opencode &>/dev/null; then
  echo "opencode not found, installing..."
  curl -fsSL https://opencode.ai/install | bash
  export PATH="$HOME/.local/bin:$PATH"
  if ! command -v opencode &>/dev/null; then
    echo "Error: opencode installation failed." >&2
    exit 1
  fi
fi

# ── Version ───────────────────────────────────────────────────────────────────
if [ "${1:-}" = "-v" ] || [ "${1:-}" = "--version" ]; then
  opencode --version
  exit 0
fi

CONFIG="$HOME/.config/opencode/opencode.json"

# ── Parse arguments ───────────────────────────────────────────────────────────
PROVIDER=""
MODEL=""
EXTRA_ARGS=()
SELECT_MODE=false
PRINT_MODE=false
SKIP_PERMS=false
CONTINUE=false

# Build list of known providers from config
PROVIDERS=()
if [ -f "$CONFIG" ]; then
  while IFS= read -r line; do
    PROVIDERS+=("$line")
  done < <(node -e "
    const config = require('$CONFIG');
    Object.keys(config.provider || {}).forEach(p => console.log(p));
  " 2>/dev/null || true)
fi

if [ $# -gt 0 ]; then
  ARGS=("$@")
  USED=()
  IDX=0

  for arg in "${ARGS[@]}"; do
    case "$arg" in
      -s|--select)
        SELECT_MODE=true
        USED+=("$IDX")
        ;;
      -p|--print)
        PRINT_MODE=true
        USED+=("$IDX")
        ;;
      -c)
        CONTINUE=true
        EXTRA_ARGS+=("-c")
        USED+=("$IDX")
        ;;
      --dangerously-skip-permissions)
        SKIP_PERMS=true
        USED+=("$IDX")
        ;;
      -m|--model)
        USED+=("$IDX")
        IDX=$((IDX + 1))
        if [ "$IDX" -lt "${#ARGS[@]}" ]; then
          MODEL="${ARGS[$IDX]}"
          USED+=("$IDX")
        fi
        ;;
      -*)
        # Unknown flag, pass through
        EXTRA_ARGS+=("$arg")
        USED+=("$IDX")
        ;;
      *)
        # Non-flag: provider or model
        if [ -z "$PROVIDER" ]; then
          IS_PROVIDER=false
          for p in "${PROVIDERS[@]}"; do
            if [ "$arg" = "$p" ]; then
              IS_PROVIDER=true
              break
            fi
          done
          if $IS_PROVIDER; then
            PROVIDER="$arg"
            USED+=("$IDX")
          else
            EXTRA_ARGS+=("$arg")
            USED+=("$IDX")
          fi
        elif [ -z "$MODEL" ]; then
          # After provider, next non-flag arg = model
          MODEL="$arg"
          USED+=("$IDX")
        else
          EXTRA_ARGS+=("$arg")
          USED+=("$IDX")
        fi
        ;;
    esac
    IDX=$((IDX + 1))
  done

  # Collect remaining unused args
  IDX=0
  for arg in "${ARGS[@]}"; do
    USED_FLAG=false
    for u in "${USED[@]}"; do
      if [ "$IDX" -eq "$u" ]; then
        USED_FLAG=true
        break
      fi
    done
    if ! $USED_FLAG; then
      EXTRA_ARGS+=("$arg")
    fi
    IDX=$((IDX + 1))
  done
fi

# ── Interactive model selection via fzf ───────────────────────────────────────
if $SELECT_MODE; then
  if [ ! -f "$CONFIG" ]; then
    echo "Error: Config not found: $CONFIG" >&2
    exit 1
  fi

  RESULT=$(node -e "
    const c = require('$CONFIG');
    for (const [pk, p] of Object.entries(c.provider || {})) {
      if (pk === 'mimo') continue;
      const pn = p.name || pk;
      for (const [mk, m] of Object.entries(p.models || {})) {
        const mn = m.name || mk;
        const ctx = m.limit?.context;
        const s = ctx >= 1048576 ? (ctx/1048576).toFixed(0)+'M' : ctx >= 1024 ? (ctx/1024).toFixed(0)+'K' : ctx;
        console.log(pk+'\\\\'+mk+'\\t'+pn+' / '+mn+' ('+s+')');
      }
    }
  " 2>/dev/null | command fzf \
    --delimiter '\t' --with-nth 2 \
    --header 'Select provider / model' \
    --height 90% --layout=reverse --border \
    --no-preview \
  ) || exit 1

  _key=$(printf '%s' "$RESULT" | cut -d$'\t' -f1)
  PROVIDER=$(printf '%s' "$_key" | awk -F'\\' '{print $1}')
  MODEL=$(printf '%s' "$_key" | awk -F'\\' '{print $2}')

  echo "Selected: $PROVIDER / $MODEL"
fi

# ── Default to mimo (free) if no provider/model and no extra args ────────────
if [ -z "$PROVIDER" ] && [ -z "$MODEL" ] && [ ${#EXTRA_ARGS[@]} -eq 0 ]; then
  PROVIDER="mimo"
  MODEL="mimo-v2.5"
fi

# ── Build command ─────────────────────────────────────────────────────────────
CMD=(opencode run)

if [ -n "$PROVIDER" ] && [ -n "$MODEL" ]; then
  CMD+=("-m" "$PROVIDER/$MODEL")
elif [ -n "$MODEL" ]; then
  CMD+=("-m" "$MODEL")
fi

if $SKIP_PERMS; then
  CMD+=("--dangerously-skip-permissions")
fi

# ── Execute ───────────────────────────────────────────────────────────────────
if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
  # Has positional args → non-interactive run mode
  CMD+=("${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}")
  exec "${CMD[@]}"
else
  # No args → continue last session, skip permissions
  exec opencode -c --dangerously-skip-permissions
fi
