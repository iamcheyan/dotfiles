#!/usr/bin/env bash
# Show subscription quota/usage information for local agent CLIs.
#
# Usage:
#   aq
#   aq --json        # raw JSON for providers that expose structured data

set -euo pipefail

export FNM_DIR="${FNM_DIR:-$HOME/.fnm}"
export PATH="$HOME/.local/bin:$HOME/.antigravity/bin:$HOME/.grok/bin:$FNM_DIR:$FNM_DIR/bin:$HOME/.local/share/fnm:$HOME/.local/bin:$PATH"

if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --shell bash)"
  fnm use default >/dev/null 2>&1 || true
  npm_bin="$(npm config get prefix 2>/dev/null)/bin"
  [ -d "$npm_bin" ] && export PATH="$npm_bin:$PATH"
fi

JSON_MODE=false
case "${1:-}" in
  --json)
    JSON_MODE=true
    ;;
  -h|--help)
    sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  "")
    ;;
  *)
    echo "Usage: aq [--json]" >&2
    exit 1
    ;;
esac

have() {
  command -v "$1" >/dev/null 2>&1
}

line() {
  printf '%s\n' "$*"
}

section() {
  printf '\n== %s ==\n' "$1"
}

human_time() {
  local epoch="${1:-}"
  if [ -z "$epoch" ] || [ "$epoch" = "null" ]; then
    printf 'unknown'
    return
  fi

  if date -d "@$epoch" '+%Y-%m-%d %H:%M:%S %Z' >/dev/null 2>&1; then
    date -d "@$epoch" '+%Y-%m-%d %H:%M:%S %Z'
  else
    date -r "$epoch" '+%Y-%m-%d %H:%M:%S %Z'
  fi
}

duration_mins() {
  local mins="${1:-}"
  case "$mins" in
    60) printf 'hourly' ;;
    300) printf '5-hour' ;;
    1440) printf 'daily' ;;
    10080) printf 'weekly' ;;
    43200|44640) printf 'monthly-ish' ;;
    ""|null) printf 'unknown' ;;
    *) printf '%s min' "$mins" ;;
  esac
}

format_tokens() {
  local n="${1:-0}"
  awk -v n="$n" 'BEGIN {
    if (n >= 1000000000) printf "%.2fB", n / 1000000000;
    else if (n >= 1000000) printf "%.2fM", n / 1000000;
    else if (n >= 1000) printf "%.1fK", n / 1000;
    else printf "%d", n;
  }'
}

# Draw a usage bar. Args: percent (0-100), [width]
#   solid block (█) = consumed (used) portion
#   dash (─)        = remaining (available) portion
# All three providers (Grok, Codex, AGY) report a used-style fraction here,
# matching each provider's native bar (solid = consumed / quota left).
bar() {
  local pct="${1:-0}" width="${2:-30}"
  case "$pct" in
    ''|null) pct=0 ;;
  esac
  pct="$(awk -v p="$pct" 'BEGIN { if (p < 0) p = 0; if (p > 100) p = 100; printf "%d", p }')"
  local filled
  filled="$(awk -v p="$pct" -v w="$width" 'BEGIN { printf "%d", int(p/100*w + 0.5) }')"
  local empty=$(( width - filled ))
  local i solid="" dash=""
  for ((i = 0; i < filled; i++)); do solid+="█"; done
  for ((i = 0; i < empty; i++)); do dash+="─"; done
  printf '  [%s%s] %s%%' "$solid" "$dash" "$pct"
}

codex_json() {
  node <<'NODE'
const { spawn } = require("child_process");

const child = spawn("codex", ["app-server", "--stdio"], {
  stdio: ["pipe", "pipe", "pipe"],
});

let buffer = "";
let stderr = "";
const responses = new Map();
const notifications = [];

function send(id, method, params) {
  const msg = params === undefined ? { id, method } : { id, method, params };
  child.stdin.write(JSON.stringify(msg) + "\n");
}

function handleLine(line) {
  if (!line.trim()) return;
  try {
    const msg = JSON.parse(line);
    if (Object.prototype.hasOwnProperty.call(msg, "id")) {
      responses.set(msg.id, msg);
    } else {
      notifications.push(msg);
    }
  } catch (error) {
    stderr += `\nFailed to parse stdout line: ${line}`;
  }
}

child.stdout.on("data", (chunk) => {
  buffer += chunk.toString();
  let idx;
  while ((idx = buffer.indexOf("\n")) >= 0) {
    const line = buffer.slice(0, idx);
    buffer = buffer.slice(idx + 1);
    handleLine(line);
  }
});

child.stderr.on("data", (chunk) => {
  stderr += chunk.toString();
});

function waitFor(id, timeoutMs) {
  const started = Date.now();
  return new Promise((resolve, reject) => {
    const timer = setInterval(() => {
      if (responses.has(id)) {
        clearInterval(timer);
        resolve(responses.get(id));
      } else if (Date.now() - started > timeoutMs) {
        clearInterval(timer);
        reject(new Error(`timeout waiting for response id ${id}`));
      }
    }, 50);
  });
}

(async () => {
  try {
    send(1, "initialize", {
      clientInfo: { name: "agent-quota", title: "Agent Quota", version: "0.1.0" },
      capabilities: null,
    });
    await waitFor(1, 5000);

    send(2, "account/read", { refreshAuth: true });
    send(3, "account/rateLimits/read");
    send(4, "account/usage/read");

    const [account, rateLimits, usage] = await Promise.all([
      waitFor(2, 15000),
      waitFor(3, 15000),
      waitFor(4, 15000),
    ]);

    child.kill("SIGTERM");
    console.log(JSON.stringify({
      ok: true,
      account: account.result || null,
      rateLimits: rateLimits.result || null,
      usage: usage.result || null,
      notifications,
    }));
  } catch (error) {
    child.kill("SIGTERM");
    console.log(JSON.stringify({ ok: false, error: error.message, stderr }));
    process.exitCode = 1;
  }
})();
NODE
}

show_codex() {
  section "Codex"
  if ! have codex; then
    line "status: codex command not found"
    return
  fi
  if ! have node || ! have jq; then
    line "status: requires node and jq"
    return
  fi

  local data
  if ! data="$(codex_json)"; then
    line "status: failed"
    jq -r '.error // empty, .stderr // empty' <<<"$data" 2>/dev/null || printf '%s\n' "$data"
    return
  fi

  if $JSON_MODE; then
    jq '{codex: .}' <<<"$data"
    return
  fi

  local email plan
  email="$(jq -r '.account.account.email // "unknown"' <<<"$data")"
  plan="$(jq -r '.account.account.planType // "unknown"' <<<"$data")"
  line "account: $email"
  line "plan: $plan"

  jq -c '
    .rateLimits.rateLimitsByLimitId
    // (if .rateLimits.rateLimits then {(.rateLimits.rateLimits.limitId // "default"): .rateLimits.rateLimits} else {} end)
    | to_entries[]
  ' <<<"$data" | while IFS= read -r entry; do
    local key name used window reset secondary_used secondary_window secondary_reset credits unlimited balance reached
    key="$(jq -r '.key' <<<"$entry")"
    name="$(jq -r '.value.limitName // .value.limitId // .key' <<<"$entry")"
    used="$(jq -r '.value.primary.usedPercent // empty' <<<"$entry")"
    window="$(jq -r '.value.primary.windowDurationMins // empty' <<<"$entry")"
    reset="$(jq -r '.value.primary.resetsAt // empty' <<<"$entry")"
    secondary_used="$(jq -r '.value.secondary.usedPercent // empty' <<<"$entry")"
    secondary_window="$(jq -r '.value.secondary.windowDurationMins // empty' <<<"$entry")"
    secondary_reset="$(jq -r '.value.secondary.resetsAt // empty' <<<"$entry")"
    unlimited="$(jq -r '.value.credits.unlimited // false' <<<"$entry")"
    balance="$(jq -r '.value.credits.balance // empty' <<<"$entry")"
    credits="$(jq -r '.value.credits.hasCredits // false' <<<"$entry")"
    reached="$(jq -r '.value.rateLimitReachedType // empty' <<<"$entry")"

    line "limit: $name ($key)"
    if [ -n "$used" ]; then
      line "$(bar "$used")  primary $(duration_mins "$window"), resets $(human_time "$reset")"
    else
      line "  primary: unavailable"
    fi
    if [ -n "$secondary_used" ]; then
      line "$(bar "$secondary_used")  secondary $(duration_mins "$secondary_window"), resets $(human_time "$secondary_reset")"
    fi
    line "  credits: has=$credits unlimited=$unlimited balance=${balance:-0}"
    [ -n "$reached" ] && line "  reached: $reached"
  done || true

  local reset_count
  reset_count="$(jq -r '.rateLimits.rateLimitResetCredits.availableCount // 0' <<<"$data")"
  line "reset credits: $reset_count available"
  jq -r '.rateLimits.rateLimitResetCredits.credits[]? | "  - \(.title // "reset") expires \(.expiresAt // "unknown")"' <<<"$data" |
    while IFS= read -r row; do
      local epoch
      epoch="${row##* expires }"
      printf '%s\n' "${row% expires *} expires $(human_time "$epoch")"
    done || true

  local lifetime peak streak today week month
  lifetime="$(jq -r '.usage.summary.lifetimeTokens // 0' <<<"$data")"
  peak="$(jq -r '.usage.summary.peakDailyTokens // 0' <<<"$data")"
  streak="$(jq -r '.usage.summary.currentStreakDays // 0' <<<"$data")"
  today="$(jq -r --arg d "$(date +%F)" '[.usage.dailyUsageBuckets[]? | select(.startDate == $d) | .tokens] | add // 0' <<<"$data")"
  week="$(jq -r --arg d "$(date -d '6 days ago' +%F)" '[.usage.dailyUsageBuckets[]? | select(.startDate >= $d) | .tokens] | add // 0' <<<"$data")"
  month="$(jq -r --arg d "$(date -d '29 days ago' +%F)" '[.usage.dailyUsageBuckets[]? | select(.startDate >= $d) | .tokens] | add // 0' <<<"$data")"
  line "tokens: today $(format_tokens "$today"), 7d $(format_tokens "$week"), 30d $(format_tokens "$month"), lifetime $(format_tokens "$lifetime")"
  line "peak daily tokens: $(format_tokens "$peak"); current streak: ${streak}d"
}

# Convert an ISO-8601 timestamp (e.g. 2026-06-15T18:01:56Z) to a human string.
iso_time() {
  local iso="${1:-}"
  [ -z "$iso" ] || [ "$iso" = "null" ] && { printf 'unknown'; return; }
  if date -d "$iso" '+%Y-%m-%d %H:%M:%S %Z' >/dev/null 2>&1; then
    date -d "$iso" '+%Y-%m-%d %H:%M:%S %Z'
  else
    date -j -f '%Y-%m-%dT%H:%M:%SZ' "$iso" '+%Y-%m-%d %H:%M:%S %Z' 2>/dev/null || printf '%s' "$iso"
  fi
}

# Convert ISO-8601 string to UNIX epoch seconds.
iso_to_epoch() {
  local iso="${1:-}"
  [ -z "$iso" ] || [ "$iso" = "null" ] && { printf '0'; return; }
  if date -d "$iso" '+%s' >/dev/null 2>&1; then
    date -d "$iso" '+%s'
  else
    date -j -f '%Y-%m-%dT%H:%M:%SZ' "$iso" '+%s' 2>/dev/null || printf '0'
  fi
}

# Display one cached quota bucket (Google Gemini or Claude/Cloud).
# Args: label, remainingFraction, resetTime(ISO), modelCount
# NOTE: The JSON field "remainingFraction" represents the remaining quota fraction
# (e.g. 0.88 means 88% remaining, 1.0 means 100% remaining).
# We display the remaining percentage and bar, matching the official CLI TUI.
agy_bucket() {
  local label="$1" frac="$2" reset="$3" count="$4"
  local remaining now reset_secs
  now="$(date '+%s')"
  if [ -n "$frac" ] && [ "$frac" != "null" ]; then
    reset_secs="$(iso_to_epoch "$reset")"
    if [ "$reset_secs" -gt 0 ] && [ "$reset_secs" -lt "$now" ]; then
      # The quota reset date is in the past, meaning the limit has already expired
      # and the quota should be fully restored (100% remaining).
      line "$(bar 100) remaining  $label${count:+, $count models}, resets $(iso_time "$reset") (expired / cache stale)"
    else
      remaining="$(awk -v f="$frac" 'BEGIN { printf "%d", f * 100 }')"
      line "$(bar "$remaining") remaining  $label${count:+, $count models}, resets $(iso_time "$reset")"
    fi
  else
    line "  $label: unavailable"
  fi
}

# Display one live quota bucket retrieved dynamically.
# Args: label, remainingFraction, resetTimeEpoch, description
render_live_bucket() {
  local label="$1" frac="$2" reset_epoch="$3" desc="$4"
  local remaining now
  now="$(date '+%s')"
  if [ -n "$frac" ] && [ "$frac" != "null" ]; then
    remaining="$(awk -v f="$frac" 'BEGIN { printf "%d", f * 100 }')"
    
    # Calculate time remaining till reset
    local left lh lm
    left=$(( reset_epoch - now ))
    if [ "$left" -gt 0 ]; then
      lh="$(( left / 3600 ))"
      lm="$(( (left % 3600) / 60 ))"
      line "      $(bar "$remaining") remaining  $label, resets $(human_time "$reset_epoch") (in ${lh}h ${lm}m)"
    else
      # If remaining is 100%, show it as available
      if [ "$remaining" -eq 100 ]; then
        line "      $(bar 100) remaining  $label, resets $(human_time "$reset_epoch") (expired / quota available)"
      else
        line "      $(bar "$remaining") remaining  $label, resets $(human_time "$reset_epoch")"
      fi
    fi
  else
    line "      $label: unavailable"
  fi
}

show_agy() {
  section "AGY / Gemini"
  if ! have agy; then
    line "status: agy command not found"
    return
  fi
  if ! have jq; then
    line "status: requires jq"
    return
  fi

  local accounts_file="$HOME/.config/opencode/antigravity-accounts.json"
  if [ ! -f "$accounts_file" ]; then
    line "status: $accounts_file not found"
    return
  fi

  local total now script_dir active_email http_port="" agy_pid="" live_data=""
  now="$(date '+%s')"
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  
  # Find active email from Gemini CLI configuration
  active_email=""
  if [ -f "$HOME/.gemini/google_accounts.json" ]; then
    active_email=$(jq -r '.active // empty' "$HOME/.gemini/google_accounts.json" 2>/dev/null || true)
  fi

  # 1. Attempt to find real-time quota data from running language server
  local running_pids
  running_pids=$(pgrep -f "agy" || true)
  if [ -n "$running_pids" ]; then
    local latest_log
    latest_log=$(ls -t $HOME/.gemini/antigravity-cli/log/cli-*.log 2>/dev/null | head -1 || true)
    if [ -n "$latest_log" ] && [ -f "$latest_log" ]; then
      http_port=$(grep "for HTTP" "$latest_log" | grep -oP '\d{4,5}(?= for HTTP)' | tail -1 || true)
    fi
  fi

  # 2. If not running, temporarily launch language server to retrieve quota
  if [ -z "$http_port" ]; then
    agy --print "ping" >/dev/null 2>&1 &
    agy_pid=$!
    
    local count=0
    while [ $count -lt 10 ]; do
      sleep 0.5
      local latest_log
      latest_log=$(ls -t $HOME/.gemini/antigravity-cli/log/cli-*.log 2>/dev/null | head -1 || true)
      if [ -n "$latest_log" ] && [ -f "$latest_log" ]; then
        http_port=$(grep "for HTTP" "$latest_log" | grep -oP '\d{4,5}(?= for HTTP)' | tail -1 || true)
        [ -n "$http_port" ] && break
      fi
      count=$((count + 1))
    done
  fi

  # 3. Request quota summary
  if [ -n "$http_port" ]; then
    live_data=$(python3 "$script_dir/parse_quota_summary.py" "$http_port" 2>/dev/null || true)
  fi

  # 4. Clean up temporary process
  if [ -n "$agy_pid" ]; then
    kill "$agy_pid" >/dev/null 2>&1 || true
    wait "$agy_pid" >/dev/null 2>&1 || true
  fi

  total="$(jq -r '.accounts | length' "$accounts_file" 2>/dev/null || printf '0')"
  line "accounts: $total configured"

  # Iterate over every account; each carries a cachedQuota snapshot written by the
  # Antigravity CLI with Google (gemini-flash, gemini-pro) + Cloud (claude) buckets.
  jq -c '.accounts[]?' "$accounts_file" 2>/dev/null | while IFS= read -r acct; do
    local email enabled cached_at
    email="$(jq -r '.email // "unknown"' <<<"$acct")"
    enabled="$(jq -r '.enabled // false' <<<"$acct")"
    cached_at="$(jq -r '.cachedQuotaUpdatedAt // empty' <<<"$acct")"
    [ "$enabled" = "true" ] || continue

    line
    if [ "$email" = "$active_email" ] && [ -n "$live_data" ] && [ "$(jq -r '.ok' <<<"$live_data")" = "true" ]; then
      line "account: $email (live)"
      
      local g_weekly_pct g_weekly_reset g_weekly_desc
      local g_5h_pct g_5h_reset g_5h_desc
      local c_weekly_pct c_weekly_reset c_weekly_desc
      local c_5h_pct c_5h_reset c_5h_desc
      
      g_weekly_pct=$(jq -r '.groups[] | select(.name == "Gemini Models") | .limits[] | select(.id == "gemini-weekly") | .remainingFraction' <<<"$live_data")
      g_weekly_reset=$(jq -r '.groups[] | select(.name == "Gemini Models") | .limits[] | select(.id == "gemini-weekly") | .resetTime' <<<"$live_data")
      g_weekly_desc=$(jq -r '.groups[] | select(.name == "Gemini Models") | .limits[] | select(.id == "gemini-weekly") | .description' <<<"$live_data")
      
      g_5h_pct=$(jq -r '.groups[] | select(.name == "Gemini Models") | .limits[] | select(.id == "gemini-5h") | .remainingFraction' <<<"$live_data")
      g_5h_reset=$(jq -r '.groups[] | select(.name == "Gemini Models") | .limits[] | select(.id == "gemini-5h") | .resetTime' <<<"$live_data")
      g_5h_desc=$(jq -r '.groups[] | select(.name == "Gemini Models") | .limits[] | select(.id == "gemini-5h") | .description' <<<"$live_data")
      
      c_weekly_pct=$(jq -r '.groups[] | select(.name == "Claude and GPT models") | .limits[] | select(.id == "3p-weekly") | .remainingFraction' <<<"$live_data")
      c_weekly_reset=$(jq -r '.groups[] | select(.name == "Claude and GPT models") | .limits[] | select(.id == "3p-weekly") | .resetTime' <<<"$live_data")
      c_weekly_desc=$(jq -r '.groups[] | select(.name == "Claude and GPT models") | .limits[] | select(.id == "3p-weekly") | .description' <<<"$live_data")
      
      c_5h_pct=$(jq -r '.groups[] | select(.name == "Claude and GPT models") | .limits[] | select(.id == "3p-5h") | .remainingFraction' <<<"$live_data")
      c_5h_reset=$(jq -r '.groups[] | select(.name == "Claude and GPT models") | .limits[] | select(.id == "3p-5h") | .resetTime' <<<"$live_data")
      c_5h_desc=$(jq -r '.groups[] | select(.name == "Claude and GPT models") | .limits[] | select(.id == "3p-5h") | .description' <<<"$live_data")
      
      line "  google (gemini):"
      line "    Weekly Limit:"
      render_live_bucket "flash, 9 models" "$g_weekly_pct" "$g_weekly_reset" "$g_weekly_desc"
      render_live_bucket "pro, 3 models" "$g_weekly_pct" "$g_weekly_reset" "$g_weekly_desc"
      line "    Five Hour Limit:"
      render_live_bucket "antigravity-gemini-3-flash" "$g_5h_pct" "$g_5h_reset" "$g_5h_desc"
      render_live_bucket "antigravity-gemini-3.1-pro" "$g_5h_pct" "$g_5h_reset" "$g_5h_desc"
      
      line "  cloud (claude):"
      line "    Weekly Limit:"
      render_live_bucket "claude, 2 models" "$c_weekly_pct" "$c_weekly_reset" "$c_weekly_desc"
      line "    Five Hour Limit:"
      render_live_bucket "claude-5h" "$c_5h_pct" "$c_5h_reset" "$c_5h_desc"
    else
      # Fallback to local accounts file
      line "account: $email"
      if [ -n "$cached_at" ]; then
        local cached_secs age
        cached_secs="$(awk -v ms="$cached_at" 'BEGIN { printf "%d", ms / 1000 }')"
        age=$(( now - cached_secs ))
        if [ "$age" -gt 86400 ]; then
          local age_days=$(( age / 86400 ))
          line "  cached: $(human_time "$cached_secs") (⚠️  $age_days days stale! Run 'agy' or use IDE to refresh)"
        else
          line "  cached: $(human_time "$cached_secs")"
        fi
      fi

      local q
      q="$(jq -c '.cachedQuota // {}' <<<"$acct")"
      if [ "$q" = "{}" ]; then
        line "  quota: not cached yet (launch agy once to populate)"
        continue
      fi

      line "  google (gemini):"
      line "    Weekly Limit:"
      agy_bucket "flash" \
        "$(jq -r '.["gemini-flash"].remainingFraction // empty' <<<"$q")" \
        "$(jq -r '.["gemini-flash"].resetTime // empty' <<<"$q")" \
        "$(jq -r '.["gemini-flash"].modelCount // empty' <<<"$q")"
      agy_bucket "pro" \
        "$(jq -r '.["gemini-pro"].remainingFraction // empty' <<<"$q")" \
        "$(jq -r '.["gemini-pro"].resetTime // empty' <<<"$q")" \
        "$(jq -r '.["gemini-pro"].modelCount // empty' <<<"$q")"
      line "    Five Hour Limit:"
      jq -r '.rateLimitResetTimes // {} | to_entries[] | "\(.key)\t\(.value)"' <<<"$acct" 2>/dev/null |
        while IFS=$'\t' read -r rkey rts; do
          [ -n "$rts" ] || continue
          local secs left
          secs="$(awk -v ms="${rts%.*}" 'BEGIN { printf "%d", ms / 1000 }')"
          left="$(( secs - now ))"
          if [ "$left" -gt 0 ]; then
            local lh lm
            lh="$(( left / 3600 ))"
            lm="$(( (left % 3600) / 60 ))"
            line "      $(bar 0)  ${rkey##*:} resets $(human_time "$secs") (in ${lh}h ${lm}m)"
          else
            line "      $(bar 100) remaining  ${rkey##*:} resets $(human_time "$secs") (expired / quota available)"
          fi
        done

      line "  cloud (claude):"
      line "    Weekly Limit:"
      agy_bucket "claude" \
        "$(jq -r '.claude.remainingFraction // empty' <<<"$q")" \
        "$(jq -r '.claude.resetTime // empty' <<<"$q")" \
        "$(jq -r '.claude.modelCount // empty' <<<"$q")"
    fi
  done
}

# Refresh the xAI OIDC access token using the cached refresh token in
# ~/.grok/auth.json. Prefers the cached access token if still valid; otherwise
# refreshes via auth.x.ai. xAI rotates the refresh_token on every use, so the
# new refresh_token (if any) is persisted back to the auth file, mirroring grok
# CLI behavior. Prints the access token on stdout.
grok_access_token() {
  local auth_file="$HOME/.grok/auth.json"
  [ -f "$auth_file" ] || return 1
  local entry
  entry="$(jq -c 'to_entries[0]' "$auth_file" 2>/dev/null)"
  [ -n "$entry" ] || return 1
  local cid rt ekey at expires_at
  ekey="$(jq -r '.key' <<<"$entry")"
  cid="$(jq -r '.key' <<<"$entry" | sed 's#.*::##')"
  rt="$(jq -r '.value.refresh_token // empty' <<<"$entry")"
  at="$(jq -r '.value.key // empty' <<<"$entry")"
  expires_at="$(jq -r '.value.expires_at // empty' <<<"$entry")"

  # Reuse the cached access token if it is still valid (with a 60s safety margin).
  if [ -n "$at" ] && [ -n "$expires_at" ] && [ "$expires_at" != "null" ]; then
    local now exp
    now="$(date '+%s')"
    exp="$(date -u -d "$expires_at" '+%s' 2>/dev/null || date -u -d "${expires_at%.*}Z" '+%s' 2>/dev/null || printf '0')"
    if [ "$exp" -gt 0 ] && [ "$((exp - now))" -gt 60 ]; then
      printf '%s' "$at"
      return 0
    fi
  fi

  [ -n "$cid" ] && [ -n "$rt" ] || return 1

  local resp new_rt
  resp="$(curl -sS -m 15 -X POST 'https://auth.x.ai/oauth2/token' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'grant_type=refresh_token' \
    --data-urlencode "client_id=$cid" \
    --data-urlencode "refresh_token=$rt" 2>/dev/null)"
  at="$(jq -r '.access_token // empty' 2>/dev/null <<<"$resp")"
  [ -n "$at" ] || return 1

  # Persist the rotated refresh_token (and refreshed access token / expiry) back.
  new_rt="$(jq -r '.refresh_token // empty' 2>/dev/null <<<"$resp")"
  local new_exp
  new_exp="$(jq -r '.expires_in // empty' 2>/dev/null <<<"$resp")"
  local tmp
  tmp="$(mktemp)"
  if jq -c --arg k "$ekey" --arg at "$at" --arg rt "${new_rt:-$rt}" \
        --argjson exp_offset "${new_exp:-0}" \
        '.[$k].key = $at | .[$k].refresh_token = $rt' "$auth_file" >"$tmp" 2>/dev/null; then
    mv -f "$tmp" "$auth_file"
    chmod 600 "$auth_file" 2>/dev/null || true
  else
    rm -f "$tmp" 2>/dev/null || true
  fi

  printf '%s' "$at"
}

show_grok() {
  section "Grok"
  if ! have grok; then
    line "status: grok command not found"
    return
  fi
  if ! have curl || ! have jq; then
    line "status: requires curl and jq"
    return
  fi

  local at
  at="$(grok_access_token)" || at=""
  if [ -z "$at" ]; then
    line "status: no valid grok token (run \`grok login\`)"
    return
  fi

  local billing user
  billing="$(curl -sS -m 15 -H "Authorization: Bearer $at" -H 'x-grok-client-mode: grok-build' \
    'https://cli-chat-proxy.grok.com/v1/billing?format=credits' 2>/dev/null)"
  user="$(curl -sS -m 15 -H "Authorization: Bearer $at" -H 'x-grok-client-mode: grok-build' \
    'https://cli-chat-proxy.grok.com/v1/user?include=subscription' 2>/dev/null)"

  if $JSON_MODE; then
    jq -n --argjson b "$billing" --argjson u "$user" '{grok:{billing:$b,user:$u}}'
    return
  fi

  if [ -z "$billing" ] || [ "$(jq -r 'if type=="object" then has("config") else false end' <<<"$billing" 2>/dev/null)" != "true" ]; then
    line "status: failed to fetch billing"
    printf '%s\n' "$billing" | head -c 200
    return
  fi

  local email tier
  email="$(jq -r '.email // "unknown"' <<<"$user" 2>/dev/null)"
  tier="$(jq -r '.subscriptionTier // "unknown"' <<<"$user" 2>/dev/null)"
  line "account: $email"
  line "tier: $tier"

  # Grok exposes a single weekly usage group (credits) for grok-build.
  local cfg ptype pstart pend used oncap onused prepaid
  cfg="$(jq -c '.config' <<<"$billing")"
  ptype="$(jq -r '.currentPeriod.type // "unknown"' <<<"$cfg" | sed 's/USAGE_PERIOD_TYPE_//; s/.*/\L&/')"
  pstart="$(jq -r '.currentPeriod.start // empty' <<<"$cfg")"
  pend="$(jq -r '.currentPeriod.end // empty' <<<"$cfg")"
  used="$(jq -r '.creditUsagePercent // empty' <<<"$cfg")"
  oncap="$(jq -r '.onDemandCap.val // 0' <<<"$cfg")"
  onused="$(jq -r '.onDemandUsed.val // 0' <<<"$cfg")"
  prepaid="$(jq -r '.prepaidBalance.val // 0' <<<"$cfg")"

  line "limit: credits ($ptype)"
  if [ -n "$used" ]; then
    line "$(bar "$used")${pstart:+, period $(iso_time "$pstart") → $(iso_time "$pend")}"
  else
    line "  used: unavailable"
  fi
  line "  on-demand: used $(format_tokens "$onused") / cap $(format_tokens "$oncap")"
  line "  prepaid balance: $(format_tokens "$prepaid")"
  jq -r '.productUsage[]? | "  - \(.product): \(.usagePercent)%"' <<<"$cfg" 2>/dev/null
}

if $JSON_MODE; then
  codex_json_block=""
  if ! have codex; then
    codex_json_block='{"ok":false,"error":"codex command not found"}'
  elif ! have node || ! have jq; then
    codex_json_block='{"ok":false,"error":"requires node and jq"}'
  else
    codex_json_block="$(codex_json)"
  fi

  agy_block="null"
  if [ -f "$HOME/.config/opencode/antigravity-accounts.json" ] && have jq; then
    agy_block="$(jq -c '{accounts:[.accounts[]? | {email, enabled, cachedQuotaUpdatedAt, cachedQuota, rateLimitResetTimes}]}' \
      "$HOME/.config/opencode/antigravity-accounts.json" 2>/dev/null)"
  fi

  grok_block="null"
  if have grok && have curl && have jq; then
    at="$(grok_access_token)" || at=""
    if [ -n "$at" ]; then
      grok_block="$(jq -nc \
        --argjson b "$(curl -sS -m 15 -H "Authorization: Bearer $at" -H 'x-grok-client-mode: grok-build' 'https://cli-chat-proxy.grok.com/v1/billing?format=credits' 2>/dev/null || printf '{}')" \
        --argjson u "$(curl -sS -m 15 -H "Authorization: Bearer $at" -H 'x-grok-client-mode: grok-build' 'https://cli-chat-proxy.grok.com/v1/user?include=subscription' 2>/dev/null || printf '{}')" \
        '{billing:$b,user:$u}')"
    fi
  fi

  jq -n --argjson c "$codex_json_block" --argjson a "${agy_block:-null}" --argjson g "${grok_block:-null}" \
    '{codex:$c, agy:$a, grok:$g}'
else
  line "Agent quota snapshot ($(date '+%Y-%m-%d %H:%M:%S %Z'))"
  show_codex
  show_agy
  show_grok
fi
