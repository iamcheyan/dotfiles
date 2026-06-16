#!/usr/bin/env bash
# Usage:
#   cc                          # Continue last session (skip permissions)
#   cc <provider>               # Run with provider from opencode.json (uses first model)
#   cc <provider> <model>       # Run with specific model
#   cc -s, --select             # Interactive model selection (provider models)
#   cc -s --auth                # Interactive model selection (Claude native models)
#   cc -v, --version            # Show current vs latest version
#   cc --versions               # Show recent 10 versions
#   cc -c                       # Continue the most recent conversation
#   cc -r, --resume [id]        # Resume a conversation (interactive picker or by ID)
#   cc --session-id <uuid>      # Use a specific session ID
#   cc --fork-session           # Fork session when resuming
#   cc --from-pr [pr]           # Resume session linked to a PR
#   cc -p, --print <prompt>     # Non-interactive mode (print and exit)
#   cc -n, --name <name>        # Set session display name
#   cc -d, --debug [filter]     # Enable debug mode
#   cc --bare                   # Minimal mode
#   cc --effort <level>         # Set effort level (low/medium/high/xhigh/max)
#   cc -w, --worktree [name]    # Create a git worktree for this session
#   cc --permission-mode <mode> # Permission mode (acceptEdits/auto/bypassPermissions/default/dontAsk/plan)
#   cc --auth                   # Use logged-in account with default Claude model
#   cc --auth <model>           # Use logged-in account with specific Claude model
#   cc --update                 # Check and install Claude Code updates
#   cc -f                       # Force reinstall Claude Code
#   cc -install <version>       # Install a specific version of Claude Code
#
# Auth mode vs Provider mode are completely separate:
#   cc --auth                   # Logged-in account, default model (claude-sonnet-4-20250514)
#   cc --auth claude-opus-4-6   # Logged-in account, specific Claude model
#   cc mimo-anthropic           # API key from provider, provider's model
#   cc mimo-anthropic mimo-v2.5 # API key from provider, specific model
#
# Examples:
#   cc mimo-anthropic           # Uses mimo-v2.5-pro (first model)
#   cc mimo-anthropic mimo-v2.5 # Uses specific model
#   cc deepseek                 # Uses deepseek-v4-flash
#   cc kimi kimi-k2.6           # Uses kimi-k2.6
#   cc -s                       # Pick model from interactive list (provider models)
#   cc -s --auth                # Pick Claude model from interactive list
#   cc -c                       # Continue last conversation
#   cc -r                       # Interactive session picker
#   cc -r abc123-def456         # Resume specific session
#   cc -p "fix the bug"         # Non-interactive print mode
#   cc --auth                   # Logged-in account, default Claude model
#   cc --auth claude-opus-4-6   # Logged-in account, specific Claude model
#
# ── Claude Code CLI Reference ────────────────────────────────────────────────
#
# Session:
#   -c, --continue                    Continue most recent conversation
#   -r, --resume [id|search]          Resume by session ID or interactive picker
#   --session-id <uuid>               Use a specific session ID
#   --fork-session                    Fork session when resuming (with --resume/-c)
#   --from-pr [pr]                    Resume session linked to a PR
#   -n, --name <name>                 Set session display name
#   --no-session-persistence          Don't save sessions to disk (--print only)
#
# Model & Provider:
#   --model <model>                   Model for the session (alias or full name)
#   --fallback-model <model>          Fallback model(s) when primary unavailable (--print only)
#   --effort <level>                  low | medium | high | xhigh | max
#
# Input / Output:
#   -p, --print                       Non-interactive mode, print response and exit
#   --input-format <format>           text | stream-json (--print only)
#   --output-format <format>          text | json | stream-json (--print only)
#   --json-schema <schema>            JSON Schema for structured output validation
#   --include-partial-messages        Include partial message chunks (--print + stream-json)
#   --replay-user-messages            Re-emit user messages on stdout (stream-json)
#   --prompt-suggestions [bool]       Enable prompt suggestions
#   --brief                           Enable SendUserMessage tool for agent comms
#   --verbose                         Override verbose mode setting
#
# Permissions & Sandbox:
#   --dangerously-skip-permissions    Bypass all permission checks
#   --allow-dangerously-skip-permissions  Enable bypass as an option (not default)
#   --permission-mode <mode>          acceptEdits | auto | bypassPermissions |
#                                     default | dontAsk | plan
#   --safe-mode                       Disable all customizations for troubleshooting
#
# Tools:
#   --tools <tools...>                Specify available built-in tools ("" to disable)
#   --allowedTools <tools...>         Allow specific tools (e.g. "Bash(git *) Edit")
#   --disallowedTools <tools...>      Deny specific tools
#
# Context & Prompt:
#   --system-prompt <prompt>          Override system prompt
#   --append-system-prompt <prompt>   Append to default system prompt
#   --add-dir <dirs...>               Additional directories for tool access
#   --bare                            Minimal mode: skip hooks, LSP, keychain, etc.
#
# MCP & Plugins:
#   --mcp-config <configs...>         Load MCP servers from JSON files/strings
#   --strict-mcp-config               Only use MCP from --mcp-config
#   --plugin-dir <path>               Load plugin from directory or .zip (repeatable)
#   --plugin-url <url>                Fetch plugin .zip from URL (repeatable)
#
# Worktree & IDE:
#   -w, --worktree [name]             Create git worktree for session
#   --tmux                            Create tmux session for worktree
#   --ide                             Auto-connect to IDE on startup
#   --chrome                          Enable Claude in Chrome integration
#   --no-chrome                       Disable Claude in Chrome integration
#
# Remote Control:
#   --remote-control [name]           Start interactive session with Remote Control
#   --remote-control-session-name-prefix <prefix>
#
# Debug & Dev:
#   -d, --debug [filter]              Debug mode (e.g. "api,hooks", "!1p,!file")
#   --debug-file <path>               Write debug logs to file
#   --betas <betas...>                Beta headers for API requests
#   --max-budget-usd <amount>         Max API spend (--print only)
#   --exclude-dynamic-system-prompt-sections  Improve cross-user prompt-cache reuse
#   --setting-sources <sources>       Setting sources to load (user,project,local)
#   --settings <file-or-json>         Load additional settings
#   --agent <agent>                   Agent for the session
#   --agents <json>                   JSON defining custom agents
#   --disable-slash-commands          Disable all skills
#   --file <specs...>                 File resources to download at startup
#   --include-hook-events             Include hook lifecycle events (stream-json)
#
# Subcommands:
#   agents            Manage background agents
#   auth              Manage authentication
#   auto-mode         Inspect auto mode classifier config
#   doctor            Check health of auto-updater
#   install [target]  Install native build (stable/latest/specific version)
#   mcp               Configure and manage MCP servers
#   plugin|plugins    Manage plugins
#   project           Manage project state
#   setup-token       Set up long-lived auth token (Claude subscription)
#   ultrareview       Run cloud-hosted multi-agent code review
#   update|upgrade    Check and install updates
#
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

HAS_ARGS=$#

# Config file to remember last used model
CC_CONFIG="$HOME/.cache/cc_last_model"
CC_QUERY="$HOME/.cache/cc_last_query"
mkdir -p "$(dirname "$CC_CONFIG")"

export FNM_DIR="${FNM_DIR:-$HOME/.fnm}"
export PATH="$FNM_DIR:$FNM_DIR/bin:$HOME/.local/share/fnm:$HOME/.local/bin:$PATH"

if ! command -v fnm &>/dev/null; then
  echo "Error: fnm not found. Run init.sh or install fnm first." >&2
  exit 1
fi

eval "$(fnm env --shell bash)"
fnm use default >/dev/null 2>&1 || {
  fnm install --lts
  latest=$(fnm list 2>/dev/null | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n 1 || true)
  [ -n "$latest" ] && fnm default "$latest" >/dev/null || true
  fnm use default >/dev/null || true
}

# Check for -f flag (force reinstall)
FORCE_REINSTALL=false
for arg in "$@"; do
  if [ "$arg" = "-f" ]; then
    FORCE_REINSTALL=true
    break
  fi
done

if $FORCE_REINSTALL || ! command -v claude &>/dev/null; then
  echo "Installing/reinstalling @anthropic-ai/claude-code..."
  npm i -g @anthropic-ai/claude-code
fi

# Version commands
if [ "${1:-}" = "-v" ] || [ "${1:-}" = "--version" ]; then
  CURRENT=$(npm list -g @anthropic-ai/claude-code --depth=0 2>/dev/null | grep '@anthropic-ai/claude-code@' | sed 's/.*@//' || true)
  LATEST=$(npm view @anthropic-ai/claude-code version 2>/dev/null || true)
  echo "Current:  ${CURRENT:-not installed}"
  echo "Latest:   ${LATEST:-unknown}"
  if [ -n "$CURRENT" ] && [ -n "$LATEST" ] && [ "$CURRENT" = "$LATEST" ]; then
    echo "Status:   up to date ✓"
  elif [ -n "$CURRENT" ] && [ -n "$LATEST" ]; then
    echo "Status:   update available"
  fi
  exit 0
fi

if [ "${1:-}" = "--versions" ]; then
  LATEST=$(npm view @anthropic-ai/claude-code version 2>/dev/null || true)
  CURRENT=$(npm list -g @anthropic-ai/claude-code --depth=0 2>/dev/null | grep '@anthropic-ai/claude-code@' | sed 's/.*@//' || true)
  echo "Current: ${CURRENT:-not installed}  Latest: ${LATEST:-unknown}"
  echo ""
  echo "Recent versions:"
  npm view @anthropic-ai/claude-code versions --json 2>/dev/null \
    | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')).slice(-10).join('\n')"
  exit 0
fi

CONFIG="$HOME/.config/opencode/opencode.json"

# ── Parse arguments ──────────────────────────────────────────────────────────
# Two-pass approach: first identify provider/model, then collect everything
# else as passthrough args for claude.
#
# Pass 1: scan non-flag args against opencode.json providers.
#   - If a non-flag arg matches a provider name, it's consumed.
#   - If the next non-flag arg after a provider doesn't match any provider, it's the model.
# Pass 2: all remaining args (including all flags) → EXTRA_ARGS → passed to claude.

PROVIDER=""
MODEL=""
EXTRA_ARGS=()
SELECT_MODE=false
UPDATE_MODE=false
AUTH_MODE=false
INSTALL_VERSION=""

if [ $# -gt 0 ]; then
  # First pass: detect flags only (no provider lookup yet)
  for arg in "$@"; do
    if [ "$arg" = "--auth" ]; then
      AUTH_MODE=true
      break
    fi
  done

  # Build list of known providers from config (skip if auth mode)
  PROVIDERS=()
  if ! $AUTH_MODE && [ -f "$CONFIG" ]; then
    while IFS= read -r line; do
      PROVIDERS+=("$line")
    done < <(node -e "
      const config = require('$CONFIG');
      Object.keys(config.provider || {}).forEach(p => console.log(p));
    " 2>/dev/null || true)
  fi

  # Two-pass: first pass identifies provider/model, second collects extras
  ARGS=("$@")
  USED=() # track indices consumed by provider/model
  IDX=0

  for arg in "${ARGS[@]}"; do
    # -s / --select
    if [ "$arg" = "-s" ] || [ "$arg" = "--select" ]; then
      SELECT_MODE=true
      USED+=("$IDX")
      IDX=$((IDX + 1))
      continue
    fi

    # --update
    if [ "$arg" = "--update" ]; then
      UPDATE_MODE=true
      USED+=("$IDX")
      IDX=$((IDX + 1))
      continue
    fi

    # --auth
    if [ "$arg" = "--auth" ]; then
      AUTH_MODE=true
      USED+=("$IDX")
      IDX=$((IDX + 1))
      continue
    fi

    # -install <version>
    if [ "$arg" = "-install" ]; then
      # Peek ahead for the version number
      NEXT_IDX=$((IDX + 1))
      if [ "$NEXT_IDX" -lt "${#ARGS[@]}" ]; then
        INSTALL_VERSION="${ARGS[$NEXT_IDX]}"
        USED+=("$IDX")
        USED+=("$NEXT_IDX")
      else
        echo "Error: -install requires a version number (e.g., -install 2.1.150)" >&2
        exit 1
      fi
      IDX=$((IDX + 2))
      continue
    fi

    # Non-flag arg: could be provider or model
    if [[ "$arg" != -* ]]; then
      if $AUTH_MODE; then
        # In auth mode, non-flag args are model names, not providers
        if [ -z "$MODEL" ]; then
          MODEL="$arg"
          USED+=("$IDX")
        fi
      else
        # Provider mode: check against known providers
        if [ -n "$PROVIDER" ] && [ -n "$MODEL" ]; then
          IDX=$((IDX + 1))
          continue
        fi
        IS_PROVIDER=false
        if [ ${#PROVIDERS[@]} -gt 0 ]; then
          for p in "${PROVIDERS[@]}"; do
            if [ "$arg" = "$p" ]; then
              IS_PROVIDER=true
              break
            fi
          done
        fi
        if $IS_PROVIDER && [ -z "$PROVIDER" ]; then
          PROVIDER="$arg"
          USED+=("$IDX")
          # Peek ahead: next non-flag arg that isn't a known provider = model
          JDX=$((IDX + 1))
          while [ "$JDX" -lt "${#ARGS[@]}" ]; do
            NEXT="${ARGS[$JDX]}"
            if [[ "$NEXT" == -* ]] || [ "$NEXT" = "-s" ] || [ "$NEXT" = "--select" ]; then
              JDX=$((JDX + 1))
              continue
            fi
            NEXT_IS_PROVIDER=false
            if [ ${#PROVIDERS[@]} -gt 0 ]; then
              for p in "${PROVIDERS[@]}"; do
                if [ "$NEXT" = "$p" ]; then
                  NEXT_IS_PROVIDER=true
                  break
                fi
              done
            fi
            if ! $NEXT_IS_PROVIDER; then
              MODEL="$NEXT"
              USED+=("$JDX")
            fi
            break
          done
        fi
      fi
    fi
    IDX=$((IDX + 1))
  done

  # Collect everything not used as provider/model
  IDX=0
  for arg in "${ARGS[@]}"; do
    USED_FLAG=false
    if [ ${#USED[@]} -gt 0 ]; then
      for u in "${USED[@]}"; do
        if [ "$IDX" -eq "$u" ]; then
          USED_FLAG=true
          break
        fi
      done
    fi
    if ! $USED_FLAG; then
      EXTRA_ARGS+=("$arg")
    fi
    IDX=$((IDX + 1))
  done
fi

# Interactive model selection via fzf
if $SELECT_MODE; then
  if [ ! -f "$CONFIG" ]; then
    echo "Error: Config file not found: $CONFIG" >&2
    exit 1
  fi

  if $AUTH_MODE; then
    # Auth mode: show Claude native models only (bash 3.2 compatible)
    AUTH_LABELS=(
      "Claude Sonnet 4 (default)"
      "Claude Opus 4"
      "Claude Haiku 4"
      "Claude Sonnet 4.6"
      "Claude Opus 4.6"
      "Claude Haiku 4.6"
    )
    AUTH_VALUES=(
      "claude-sonnet-4-20250514"
      "claude-opus-4-20250514"
      "claude-haiku-4-20250514"
      "claude-sonnet-4-6"
      "claude-opus-4-6"
      "claude-haiku-4-6"
    )

    RESULT=$(printf '%s\n' "${AUTH_LABELS[@]}" \
      | command fzf \
        --header 'Select Claude model (logged-in account)' \
        --height 90% --layout=reverse --border \
    ) || exit 1

    # Look up value by matching label (bash 3.2 compatible)
    MODEL=""
    for _i in "${!AUTH_LABELS[@]}"; do
      if [ "${AUTH_LABELS[$_i]}" = "$RESULT" ]; then
        MODEL="${AUTH_VALUES[$_i]}"
        break
      fi
    done
    PROVIDER=""
    echo "Selected: $MODEL (auth mode)"

    # Save display name for next default query
    printf '%s\n' "$RESULT" > "$CC_QUERY"
  else
    # Provider mode: show all provider models
    MODEL_LINES=()
    MODEL_KEYS=()
    _idx=0
    while IFS=$'\t' read -r key label; do
      MODEL_LINES+=("$label")
      MODEL_KEYS+=("$key")
      _idx=$((_idx + 1))
    done < <(node -e "
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
    " 2>/dev/null)

    RESULT=$(printf '%s\n' "${MODEL_LINES[@]}" | command fzf \
      --header 'Select provider / model' \
      --height 90% --layout=reverse --border \
    ) || exit 1

    # Look up key by matching label (bash 3.2 compatible)
    _key=""
    for _i in "${!MODEL_LINES[@]}"; do
      if [ "${MODEL_LINES[$_i]}" = "$RESULT" ]; then
        _key="${MODEL_KEYS[$_i]}"
        break
      fi
    done
    PROVIDER=$(printf '%s' "$_key" | awk -F'\\\\' '{print $1}')
    MODEL=$(printf '%s' "$_key" | awk -F'\\\\' '{print $2}')
    echo "Selected: $PROVIDER / $MODEL"

    # Save display name for next default query
    printf '%s\n' "$RESULT" > "$CC_QUERY"
  fi
fi

# Load last used model if no provider specified
if [ -z "$PROVIDER" ] && [ -f "$CC_CONFIG" ] && [ "$HAS_ARGS" -eq 0 ]; then
  LAST_PROVIDER=$(head -1 "$CC_CONFIG" 2>/dev/null || echo "")
  LAST_MODEL=$(tail -1 "$CC_CONFIG" 2>/dev/null || echo "")
  if [ -n "$LAST_PROVIDER" ]; then
    PROVIDER="$LAST_PROVIDER"
    MODEL="${LAST_MODEL:-}"
  fi
fi

if [ -n "$PROVIDER" ] && [ -f "$CONFIG" ]; then
  PROVIDER_CONFIG=$(node -e "
    const config = require('$CONFIG');
    const p = config.provider['$PROVIDER'];
    if (!p) { console.error('Provider $PROVIDER not found'); process.exit(1); }
    const models = Object.keys(p.models);
    console.log(JSON.stringify({ apiKey: p.options.apiKey, baseURL: p.options.baseURL, models }));
  " 2>/dev/null) || { echo "Error: Provider '$PROVIDER' not found in $CONFIG" >&2; exit 1; }

  API_KEY=$(echo "$PROVIDER_CONFIG" | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')).apiKey")
  BASE_URL=$(echo "$PROVIDER_CONFIG" | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')).baseURL")
  MODELS=$(echo "$PROVIDER_CONFIG" | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')).models")

  export ANTHROPIC_API_KEY="$API_KEY"
  export ANTHROPIC_BASE_URL="$BASE_URL"

  if [ -n "$MODEL" ]; then
    export ANTHROPIC_MODEL="$MODEL"
  else
    # Use first model as default
    DEFAULT_MODEL=$(echo "$MODELS" | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'))[0]")
    export ANTHROPIC_MODEL="$DEFAULT_MODEL"
  fi
fi

# When --auth is used, completely ignore provider config — use logged-in account
if $AUTH_MODE; then
  unset ANTHROPIC_API_KEY
  unset ANTHROPIC_BASE_URL
  # If no model specified, use default Claude model
  if [ -z "${ANTHROPIC_MODEL:-}" ]; then
    export ANTHROPIC_MODEL="claude-sonnet-4-20250514"
  fi
  # In auth mode, non-flag args are treated as model name, not provider
  # (provider lookup was already skipped above)
fi

# Auto update only when --update flag is provided
if $UPDATE_MODE; then
  echo "Checking for Claude Code updates..."
  npm i -g @anthropic-ai/claude-code@latest 2>/dev/null || true
fi

# Install specific version
if [ -n "$INSTALL_VERSION" ]; then
  echo "Installing @anthropic-ai/claude-code@${INSTALL_VERSION}..."
  npm i -g "@anthropic-ai/claude-code@${INSTALL_VERSION}" || {
    echo "Error: Failed to install version ${INSTALL_VERSION}" >&2
    exit 1
  }
  echo "Installed @anthropic-ai/claude-code@${INSTALL_VERSION}"
  exit 0
fi

# Print model info
if [ -n "${ANTHROPIC_MODEL:-}" ]; then
  echo "Model: $ANTHROPIC_MODEL"
fi

# Save current model for next time (only in provider mode)
if [ -n "${PROVIDER:-}" ] && ! $AUTH_MODE; then
  echo "$PROVIDER" > "$CC_CONFIG"
  echo "${MODEL:-}" >> "$CC_CONFIG"
fi

# Debug: show auth state before launching (remove after verification)
if $AUTH_MODE; then
  echo "[cc] auth mode: ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY:+SET}${ANTHROPIC_API_KEY:-unset}, MODEL=${ANTHROPIC_MODEL:-unset}"
fi

# Build claude command args
CLAUDE_ARGS=(--dangerously-skip-permissions)

# Provider mode: use --bare to skip keychain reads (avoids OAuth + API key conflict)
if [ -n "${PROVIDER:-}" ] && ! $AUTH_MODE; then
  CLAUDE_ARGS+=(--bare)
fi

if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
  exec claude "${CLAUDE_ARGS[@]}" "${EXTRA_ARGS[@]}"
else
  exec claude "${CLAUDE_ARGS[@]}" -c
fi
