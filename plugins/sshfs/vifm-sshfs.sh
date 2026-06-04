#!/usr/bin/env bash

HOST_ALIAS="$1"
REMOTE_PATH="${2:-.}"
MOUNT_DIR="$HOME/.sshfs/$HOST_ALIAS"

if [ -z "$HOST_ALIAS" ]; then
	echo "Usage: vifm-sshfs <ssh-host> [remote-path]"
	exit 1
fi

# 修复 ~ 问题
[ "$REMOTE_PATH" = "~" ] && REMOTE_PATH="."

mkdir -p "$MOUNT_DIR"

if ! mount | grep -q "$MOUNT_DIR"; then
	echo "[INFO] Mounting $HOST_ALIAS:$REMOTE_PATH → $MOUNT_DIR"
	sshfs "$HOST_ALIAS:$REMOTE_PATH" "$MOUNT_DIR" || {
		echo "[ERROR] sshfs mount failed"
		exit 1
	}
else
	echo "[INFO] Already mounted: $MOUNT_DIR"
fi

vifm "$MOUNT_DIR" "$HOME"
