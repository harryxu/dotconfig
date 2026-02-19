#!/usr/bin/env bash

set -e

# ============================================================
# Install script for dotconfig
# Supports: Linux and macOS
# ============================================================

# ---- Environment Check ----

# Check if git is installed
if ! command -v git &>/dev/null; then
    echo "Error: git is not installed. Please install git and try again."
    exit 1
fi

# Check if ~/.config directory exists, create it if not
if [ ! -d "$HOME/.config" ]; then
    echo "Creating ~/.config directory..."
    mkdir -p "$HOME/.config"
fi

# Check if curl is installed
if ! command -v curl &>/dev/null; then
    echo "Error: curl is not installed. Please install curl and try again."
    echo ""
    echo "  macOS:         brew install curl"
    echo "  Ubuntu/Debian: sudo apt install curl"
    echo "  Fedora/RHEL:   sudo dnf install curl"
    echo "  Arch:          sudo pacman -S curl"
    echo ""
    exit 1
fi

# Check if starship is installed, install it if not
if ! command -v starship &>/dev/null; then
    echo "starship not found. Installing starship (https://starship.rs/) ..."
    curl -sS https://starship.rs/install.sh | sh
    echo "starship installed successfully."
else
    echo "starship is already installed, skipping."
fi

# ---- Clone / Setup Repository ----

if [ ! -d "$HOME/.config/.git" ]; then
    echo "Initializing dotconfig repository in ~/.config ..."
    cd "$HOME/.config"
    git init
    git remote add origin https://github.com/harryxu/dotconfig.git
    git fetch
    git checkout origin/main -ft
    echo "dotconfig repository set up successfully."
else
    echo "dotconfig repository already exists in ~/.config, skipping clone."
fi

# ---- Enable Fish Shell ----

# Check if fish is installed
if ! command -v fish &>/dev/null; then
    echo ""
    echo "fish shell is not installed. Please install it first:"
    echo ""
    echo "  macOS:  brew install fish"
    echo "  Ubuntu/Debian: sudo apt install fish"
    echo "  Fedora/RHEL:   sudo dnf install fish"
    echo "  Arch:          sudo pacman -S fish"
    echo ""
    exit 1
fi

FISH_PATH="$(command -v fish)"

# Change the default shell to fish for the current user
if [ "$SHELL" = "$FISH_PATH" ]; then
    echo "fish shell is already the default shell for the current user."
else
    echo "Changing the default shell to fish ($FISH_PATH) ..."

    # Add fish to /etc/shells if not already present
    if ! grep -qF "$FISH_PATH" /etc/shells; then
        echo "Adding $FISH_PATH to /etc/shells (requires sudo) ..."
        echo "$FISH_PATH" | sudo tee -a /etc/shells
    fi

    chsh -s "$FISH_PATH"
    echo "Default shell changed to fish successfully."
    echo "Please log out and log back in (or open a new terminal) to start using fish."
fi

echo ""
echo "✓ Installation complete!"
