#!/bin/bash

# LMDE 7 Hibernate Configuration Script (Interactive)
# Based on the user's "LMDE 7 Hibernate Configuration Manual"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
ask_confirm() {
    read -p "$1 [y/N]: " choice
    case "$choice" in 
        y|Y ) return 0 ;;
        * ) return 1 ;;
    esac
}

# Check for sudo/root
if [ "$EUID" -ne 0 ]; then
    log_warn "This script requires root privileges to modify system configuration."
    exec sudo "$0" "$@"
fi

clear
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}   LMDE 7 Hibernate (休眠) Configuration Helper   ${NC}"
echo -e "${GREEN}=============================================${NC}"
echo ""
echo "This script will guide you through configuring Hibernate on LMDE 7."
echo "It follows the manual's strict requirements regarding Swap size and Kernel support."
echo ""

# --- Step 1: Prerequisite Checks ---

log_info "Step 1: Checking Prerequisites..."

# 1.1 Kernel Support
log_info "Checking kernel support for hibernation (S4)..."
if grep -q "disk" /sys/power/state; then
    log_success "Kernel supports hibernation (found 'disk' in /sys/power/state)."
else
    log_error "Kernel does not support hibernation (missing 'disk' in /sys/power/state)."
    log_error "This might be a BIOS setting (ACPI S4) or kernel limitation."
    exit 1
fi

# 1.2 Swap vs RAM
log_info "Checking memory and swap sizes..."
mem_total_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
swap_total_kb=$(grep SwapTotal /proc/meminfo | awk '{print $2}')

# Convert to human readable for display
mem_human=$(numfmt --to=iec --from-unit=1024 $mem_total_kb)
swap_human=$(numfmt --to=iec --from-unit=1024 $swap_total_kb)

echo "   Memory: $mem_human"
echo "   Swap:   $swap_human"

if [ "$swap_total_kb" -lt "$mem_total_kb" ]; then
    log_warn "Swap is smaller than Memory!"
    log_warn "Hibernate requires Swap >= Memory to be safe."
    if ask_confirm "Do you want to proceed anyway? (Not recommended, hibernation will likely fail)"; then
        log_warn "Proceeding at your own risk..."
    else
        log_error "Aborted by user."
        exit 1
    fi
else
    log_success "Swap size is sufficient."
fi

# --- Step 2: Select Swap Partition ---

log_info "Step 2: Identifying Swap Partition..."

# Get active swaps
# format: NAME TYPE SIZE USED PRIO UUID
swaps=$(swapon --show=NAME,TYPE,SIZE,UUID --noheadings)

if [ -z "$swaps" ]; then
    log_error "No active swap found. Please enable swap before running this script."
    exit 1
fi

# Count swaps
swap_count=$(echo "$swaps" | wc -l)

if [ "$swap_count" -eq 1 ]; then
    swap_uuid=$(echo "$swaps" | awk '{print $4}')
    swap_dev=$(echo "$swaps" | awk '{print $1}')
    log_info "Found single swap device: $swap_dev (UUID: $swap_uuid)"
else
    echo "Found multiple swap devices:"
    echo "$swaps"
    echo ""
    read -p "Enter the UUID of the swap device you want to use for hibernation: " swap_uuid
fi

if [ -z "$swap_uuid" ]; then
    log_error "No UUID found/provided. Cannot proceed."
    exit 1
fi

# Double check UUID format
if [[ ! "$swap_uuid" =~ ^[0-9a-fA-F-]{36}$ ]]; then
    log_warn "The UUID '$swap_uuid' does not look like a standard UUID."
    if ! ask_confirm "Are you sure this is correct?"; then
        exit 1
    fi
fi

log_success "Target Swap UUID: $swap_uuid"

# --- Step 3: Configure GRUB ---

log_info "Step 3: Configuring GRUB..."

grub_file="/etc/default/grub"
backup_suffix=".bak.$(date +%F_%H-%M-%S)"

# Backup
cp "$grub_file" "${grub_file}${backup_suffix}"
log_info "Backed up GRUB config to ${grub_file}${backup_suffix}"

# Check if resume is already present
current_cmdline=$(grep "^GRUB_CMDLINE_LINUX_DEFAULT=" "$grub_file")
if echo "$current_cmdline" | grep -q "resume="; then
    log_warn "Existing 'resume=' parameter found in GRUB config."
    echo "Current line: $current_cmdline"
    if ask_confirm "Do you want to replace it with the new UUID?"; then
        # Remove old resume parameter(s) and add new one
        # This regex removes resume=... until the next space or quote
        sed -i 's/resume=[^ "]*//g' "$grub_file"
        # Add new one
        sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"resume=UUID=$swap_uuid /" "$grub_file"
        log_success "Updated GRUB config with new resume UUID."
    else
        log_info "Skipping GRUB modification."
    fi
else
    # Simply prepend inside the quotes
    sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"resume=UUID=$swap_uuid /" "$grub_file"
    log_success "Added resume parameter to GRUB config."
fi


# --- Step 4: Configure initramfs ---

log_info "Step 4: Configuring initramfs..."

initramfs_file="/etc/initramfs-tools/conf.d/resume"

if [ -f "$initramfs_file" ]; then
    log_info "$initramfs_file exists. Overwriting."
else
    log_info "Creating $initramfs_file."
fi

echo "RESUME=UUID=$swap_uuid" > "$initramfs_file"
log_success "Written UUID to $initramfs_file"


# --- Step 5: Optional Tweaks (Cinnamon & Polkit) ---

echo ""
log_info "Step 5: Optional Configuration"

# 5.1 Systemd LoginD / Cinnamon Workaround
echo "Some desktop environments (like Cinnamon) might inhibit hibernation."
echo "We can configure systemd-logind to ignore these inhibitors."
if ask_confirm "Do you want to enable 'HibernateKeyIgnoreInhibited=yes' in logind.conf?"; then
    logind_conf="/etc/systemd/logind.conf"
    if grep -q "^#HibernateKeyIgnoreInhibited=" "$logind_conf"; then
        sed -i "s/^#HibernateKeyIgnoreInhibited=.*/HibernateKeyIgnoreInhibited=yes/" "$logind_conf"
    elif grep -q "^HibernateKeyIgnoreInhibited=" "$logind_conf"; then
        sed -i "s/^HibernateKeyIgnoreInhibited=.*/HibernateKeyIgnoreInhibited=yes/" "$logind_conf"
    else
        echo "HibernateKeyIgnoreInhibited=yes" >> "$logind_conf"
    fi
    log_success "Updated logind.conf."
fi

# 5.2 Add Hibernate to Menu
echo ""
echo "LMDE doesn't show the Hibernate option in the shutdown menu by default."
if ask_confirm "Do you want to add 'Hibernate' to the system menu (Polkit rule)?"; then
    polkit_file="/etc/polkit-1/localauthority/50-local.d/hibernate.pkla"
    mkdir -p "$(dirname "$polkit_file")"
    cat > "$polkit_file" <<EOF
[Enable Hibernate]
Identity=unix-user:*
Action=org.freedesktop.login1.hibernate
ResultActive=yes
EOF
    log_success "Created Polkit rule at $polkit_file"
fi


# --- Step 6: Applying Changes ---

echo ""
log_info "Step 6: Applying Changes (Running updates)..."
echo "This might take a minute."

echo ">> Running update-initramfs -u -k all..."
update-initramfs -u -k all

echo ">> Running update-grub..."
update-grub

# Restart logind if we touched it? 
# Usually a reboot is best, but we can try strictly for logind changes.
# But since we need reboot for kernel params anyway, let's just wait for reboot.


# --- Step 7: Summary ---

echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}       Configuration Complete!               ${NC}"
echo -e "${GREEN}=============================================${NC}"
echo ""
echo "Next Steps:"
echo "1. Reboot your system."
echo "2. Check validation commands:"
echo "   $ cat /proc/cmdline  (should show resume=UUID=...)"
echo "   $ swapon --show      (should show active swap)"
echo "3. Test Hibernate:"
echo "   $ sudo systemctl hibernate"
echo ""
log_info "Please reboot to enable hibernation."

exit 0
