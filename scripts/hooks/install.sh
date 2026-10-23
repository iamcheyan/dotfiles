#!/bin/bash
# Install the privacy scan git hooks into this repository (or another repo).
# Usage: scripts/hooks/install.sh [target-repo-path]
set -eu
SRC="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-$(git rev-parse --show-toplevel)}"
HOOKS="$TARGET/.git/hooks"
mkdir -p "$HOOKS"
cp "$SRC/privacy_scan.py" "$HOOKS/privacy_scan.py"
for hook in pre-commit pre-push commit-msg; do
    cp "$SRC/$hook" "$HOOKS/$hook"
    chmod +x "$HOOKS/$hook"
done
echo "Privacy hooks installed in $HOOKS"
