#!/bin/bash

# This script checks the theme in theme.toml and clones it from a git repository
# if it does not exist locally.

# Set base paths
# Correcting the path from .dotfiles to Dotfiles as per the project structure
YAZI_CONFIG_DIR="/home/hkaku/Dotfiles/config/yazi"
FLAVORS_DIR="${YAZI_CONFIG_DIR}/flavors"

# --- Theme to Git Repo Mapping ---
# Add more themes here as needed.
declare -A theme_repos
theme_repos["kanagawa"]="https://github.com/dangooddd/kanagawa.yazi.git"
# e.g., theme_repos["dracula"]="https://github.com/dracula/yazi.git"

# Ensure flavors directory exists
mkdir -p "$FLAVORS_DIR"

# Read the theme name from theme.toml
theme_name=$(grep -E '^\s*dark\s*=\s*".*"' "${YAZI_CONFIG_DIR}/theme.toml" | sed -E 's/.*"(.*)".*/\1/')

if [ -z "$theme_name" ]; then
    echo "Error: Could not extract theme name from theme.toml."
    exit 1
fi

echo "Current theme set to: '$theme_name'"

# The directory for the theme is expected to be 'themename.yazi'
theme_dir_name="${theme_name}.yazi"
theme_path="${FLAVORS_DIR}/${theme_dir_name}"

if [ -d "$theme_path" ]; then
    echo "Theme '$theme_name' already exists at: ${theme_path}"
    exit 0
fi

# If theme doesn't exist, try to clone it
echo "Theme '${theme_name}' not found locally."

repo_url=${theme_repos["$theme_name"]}

if [ -z "$repo_url" ]; then
    echo "Error: Git repository for theme '${theme_name}' is not defined in the init.sh script."
    echo "Please add it to the 'theme_repos' mapping."
    exit 1
fi

echo "Attempting to clone from: ${repo_url}"

# Clone the repository directly into the flavors directory
git clone "${repo_url}" "${theme_path}"

if [ $? -eq 0 ]; then
    echo "Theme '${theme_name}' cloned successfully to ${theme_path}"
else
    echo "Error: Failed to clone theme '${theme_name}' from ${repo_url}"
    exit 1
fi

exit 0
