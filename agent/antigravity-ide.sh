#!/usr/bin/env bash
# Antigravity IDE Installer / Launcher
#
# Usage:
#   antigravity-ide             # Install if needed, then launch
#   antigravity-ide -f          # Force reinstall
#
# Supports: macOS (arm64/x64), Linux (x64/arm64)
# Install locations:
#   macOS:  /Applications/Antigravity IDE.app
#   Linux:  ~/.local/share/antigravity-ide/ (+ desktop entry)

set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

# ── Constants ────────────────────────────────────────────────────────────────
RELEASES_API="https://antigravity-ide-auto-updater-974169037036.us-central1.run.app/releases"
DOWNLOAD_BASE="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable"
INSTALL_DIR="$HOME/.local/share/antigravity-ide"
SYMLINK="$HOME/.local/bin/antigravity-ide"
DESKTOP_FILE="$HOME/.local/share/applications/antigravity-ide.desktop"
APP_NAME="Antigravity IDE"
VERSION_FILE="$INSTALL_DIR/.installed-version"

# ── Parse flags ──────────────────────────────────────────────────────────────
FORCE_REINSTALL=false

for arg in "$@"; do
  case "$arg" in
    -f|--force) FORCE_REINSTALL=true ;;
  esac
done

# ── Detect OS + Arch ─────────────────────────────────────────────────────────
detect_platform() {
  local os arch

  case "$(uname -s)" in
    Darwin) os="darwin" ;;
    Linux)  os="linux" ;;
    *)      echo "Error: Unsupported OS: $(uname -s)" >&2; exit 1 ;;
  esac

  case "$(uname -m)" in
    arm64|aarch64)  arch="arm" ;;
    x86_64)         arch="x64" ;;
    *)              echo "Error: Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
  esac

  echo "${os}-${arch}"
}

# ── Resolve file extension ───────────────────────────────────────────────────
get_ext() {
  local platform="$1"
  case "$platform" in
    darwin-*) echo "dmg" ;;
    linux-*)  echo "tar.gz" ;;
    *)        echo "unknown" ;;
  esac
}

# ── Check if installed ───────────────────────────────────────────────────────
is_installed() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    [[ -d "/Applications/${APP_NAME}.app" ]]
  else
    [[ -x "${INSTALL_DIR}/antigravity-ide" ]]
  fi
}

# ── Read saved version ───────────────────────────────────────────────────────
get_saved_version() {
  [[ -f "$VERSION_FILE" ]] && cat "$VERSION_FILE" || echo ""
}

# ── Get latest version from API ──────────────────────────────────────────────
get_latest_release() {
  curl -fsSL --retry 3 --connect-timeout 10 "$RELEASES_API" 2>/dev/null \
    | python3 -c "
import sys, json
data = json.load(sys.stdin)
if data:
    print(data[0]['version'] + ' ' + data[0]['execution_id'])
" 2>/dev/null || true
}

# ── Download + Install ───────────────────────────────────────────────────────
install_ide() {
  local platform="$1"
  local version="$2"
  local exec_id="$3"
  local ext
  ext=$(get_ext "$platform")

  local url="${DOWNLOAD_BASE}/${version}-${exec_id}/${platform}/Antigravity%20IDE.${ext}"
  local tmp_dir
  tmp_dir=$(mktemp -d)

  echo "⬇️  Downloading ${APP_NAME} ${version} for ${platform}..."
  echo "   $url"

  if ! curl -fSL --retry 3 --connect-timeout 30 --progress-bar \
       -o "${tmp_dir}/antigravity-ide.${ext}" "$url"; then
    echo "Error: Download failed." >&2
    rm -rf "$tmp_dir"
    exit 1
  fi

  if [[ "$(uname -s)" == "Darwin" ]]; then
    # ── macOS: mount DMG, copy .app ────────────────────────────────────────
    echo "📦 Installing to /Applications..."
    local mount_point
    mount_point=$(hdiutil attach "${tmp_dir}/antigravity-ide.dmg" -nobrowse -quiet 2>&1 | grep '/Volumes' | awk '{print $NF}') || true
    if [[ -z "$mount_point" ]]; then
      mount_point="/Volumes/${APP_NAME}"
    fi

    if [[ -d "${mount_point}/${APP_NAME}.app" ]]; then
      rm -rf "/Applications/${APP_NAME}.app" 2>/dev/null || true
      cp -R "${mount_point}/${APP_NAME}.app" "/Applications/"
      echo "✅ Installed to /Applications/${APP_NAME}.app"
    else
      local app_path
      app_path=$(find "$mount_point" -maxdepth 1 -name "*.app" -type d | head -1)
      if [[ -n "$app_path" ]]; then
        rm -rf "/Applications/$(basename "$app_path")" 2>/dev/null || true
        cp -R "$app_path" "/Applications/"
        echo "✅ Installed to /Applications/$(basename "$app_path")"
      else
        echo "Error: Could not find .app in mounted DMG" >&2
        hdiutil detach "$mount_point" -quiet 2>/dev/null || true
        rm -rf "$tmp_dir"
        exit 1
      fi
    fi

    hdiutil detach "$mount_point" -quiet 2>/dev/null || true

  else
    # ── Linux: extract tar.gz ──────────────────────────────────────────────
    echo "📦 Installing to ${INSTALL_DIR}..."
    mkdir -p "$INSTALL_DIR"

    tar -xzf "${tmp_dir}/antigravity-ide.tar.gz" -C "$tmp_dir"

    local extracted_dir
    extracted_dir=$(find "$tmp_dir" -maxdepth 1 -type d -name "*ntigravity*" ! -name "$(basename "$tmp_dir")" | head -1)

    if [[ -z "$extracted_dir" ]]; then
      extracted_dir="$tmp_dir"
    fi

    rm -rf "${INSTALL_DIR:?}/"*
    cp -a "${extracted_dir}/." "$INSTALL_DIR/"

    # Find the main binary
    local binary=""
    for candidate in "antigravity-ide" "Antigravity IDE" "antigravity-ide-bin" "antigravity"; do
      if [[ -x "${INSTALL_DIR}/${candidate}" ]]; then
        binary="${INSTALL_DIR}/${candidate}"
        break
      fi
    done

    if [[ -z "$binary" ]]; then
      binary=$(find "$INSTALL_DIR" -maxdepth 1 -type f -executable ! -name "*.sh" | head -1)
    fi

    if [[ -z "$binary" ]]; then
      echo "Error: Could not find binary in extracted archive" >&2
      ls -la "$INSTALL_DIR" >&2
      rm -rf "$tmp_dir"
      exit 1
    fi

    # Create symlink
    mkdir -p "$(dirname "$SYMLINK")"
    ln -sf "$binary" "$SYMLINK"
    chmod +x "$binary"

    # Create .desktop launcher
    mkdir -p "$(dirname "$DESKTOP_FILE")"
    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Antigravity IDE
Comment=Google Antigravity IDE
Exec=$binary %F
Icon=antigravity-ide
Type=Application
Categories=Development;IDE;
MimeType=x-scheme-handler/antigravity-ide;
StartupWMClass=antigravity-ide
EOF
    chmod 644 "$DESKTOP_FILE"
    command -v update-desktop-database &>/dev/null && \
      update-desktop-database "$(dirname "$DESKTOP_FILE")" 2>/dev/null || true

    echo "✅ Installed to ${INSTALL_DIR}"
    echo "   Binary: $binary"
    echo "   Symlink: $SYMLINK"
    echo "   Launcher: $DESKTOP_FILE"
  fi

  # Save installed version
  echo "$version" > "$VERSION_FILE"
  rm -rf "$tmp_dir"
}

# ── Main ─────────────────────────────────────────────────────────────────────

PLATFORM=$(detect_platform)

# Fetch latest release
RELEASE=$(get_latest_release)
if [[ -z "$RELEASE" ]]; then
  if ! is_installed; then
    echo "Error: Not installed and could not fetch latest version from API." >&2
    exit 1
  else
    echo "⚠️  Could not check for updates (API unreachable)."
  fi
fi

if [[ -n "$RELEASE" ]]; then
  LATEST_VERSION="${RELEASE%% *}"
  EXEC_ID="${RELEASE##* }"
fi

# ── Not installed → install ──────────────────────────────────────────────────
if ! is_installed; then
  echo "🔍 Installing ${APP_NAME} ${LATEST_VERSION}..."
  install_ide "$PLATFORM" "$LATEST_VERSION" "$EXEC_ID"
# ── Force reinstall ──────────────────────────────────────────────────────────
elif $FORCE_REINSTALL; then
  echo "🔍 Reinstalling ${APP_NAME} ${LATEST_VERSION}..."
  install_ide "$PLATFORM" "$LATEST_VERSION" "$EXEC_ID"
# ── Installed + version available → check for update ─────────────────────────
elif [[ -n "${LATEST_VERSION:-}" ]]; then
  SAVED=$(get_saved_version)
  if [[ -n "$SAVED" && "$SAVED" != "$LATEST_VERSION" ]]; then
    echo "⬆️  Update available: ${SAVED} → ${LATEST_VERSION}, updating..."
    install_ide "$PLATFORM" "$LATEST_VERSION" "$EXEC_ID"
  fi
fi

# ── Launch ───────────────────────────────────────────────────────────────────
if [[ "$(uname -s)" == "Darwin" ]]; then
  echo "🚀 Launching ${APP_NAME}..."
  open -a "/Applications/${APP_NAME}.app"
else
  LAUNCH_CMD=""
  if [[ -x "$SYMLINK" ]]; then
    LAUNCH_CMD="$SYMLINK"
  elif [[ -x "${INSTALL_DIR}/antigravity-ide" ]]; then
    LAUNCH_CMD="${INSTALL_DIR}/antigravity-ide"
  fi

  if [[ -z "$LAUNCH_CMD" ]]; then
    echo "Error: Binary not found." >&2
    exit 1
  fi

  # Try desktop-aware launchers first (fully detached from script)
  if command -v gio &>/dev/null && [[ -f "$DESKTOP_FILE" ]]; then
    echo "🚀 Launching ${APP_NAME}..."
    gio launch "$DESKTOP_FILE" 2>/dev/null &
  elif command -v gtk-launch &>/dev/null; then
    echo "🚀 Launching ${APP_NAME}..."
    gtk-launch antigravity-ide 2>/dev/null &
  else
    # Fallback: setsid detaches into new session, survives script exit
    echo "🚀 Launching ${APP_NAME} (via setsid)..."
    setsid "$LAUNCH_CMD" </dev/null &>/dev/null &
  fi
fi
