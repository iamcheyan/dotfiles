#!/bin/bash

# ==============================================================================
# Fedora Initialization Script (Btrfs Snapshots, GRUB, Goenv)
# ==============================================================================

set -e

echo "Starting system initialization..."

# 1. Btrfs & GRUB Snapshots Setup
echo "[1/3] Setting up Btrfs snapshots and GRUB integration..."
if ! rpm -q grub-btrfs >/dev/null 2>&1; then
    sudo dnf copr enable -y kylegospo/grub-btrfs
    sudo dnf install -y grub-btrfs
fi

if ! rpm -q snapper >/dev/null 2>&1; then
    sudo dnf install -y snapper python3-dnf-plugin-snapper
    # Create config if not exists
    if [ ! -f /etc/snapper/configs/root ]; then
        sudo snapper -c root create-config /
        # Fix .snapshots subvolume issue on Fedora
        [ -d /.snapshots ] && sudo rm -rf /.snapshots
        sudo btrfs subvolume create /.snapshots
    fi
fi

# Fix grub-btrfs.path if it's broken (dependency on non-existent mount)
if [ ! -f /etc/systemd/system/grub-btrfs.path ]; then
    echo "Applying grub-btrfs.path fix..."
    sudo cp /usr/lib/systemd/system/grub-btrfs.path /etc/systemd/system/grub-btrfs.path
    sudo sed -i '/Requires=/d; /After=/d; /BindsTo=/d; s/WantedBy=.*/WantedBy=multi-user.target/' /etc/systemd/system/grub-btrfs.path
    sudo systemctl daemon-reload
fi

sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer grub-btrfs.path
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# 2. Goenv Installation
echo "[2/3] Setting up goenv..."
if [ ! -d "$HOME/.goenv" ]; then
    git clone https://github.com/syndbg/goenv.git ~/.goenv
else
    echo "goenv already installed."
fi

# 3. Finalize Zsh
echo "[3/3] Finalizing shell configuration..."
# The .zshrc has already been patched to check for 'command -v goenv'
# to avoid p10k instant prompt issues.

echo "Initialization complete! Please restart your shell."
