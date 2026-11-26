#!/usr/bin/env bash

set -e

# ============================================================
# Install script for dotconfig
# Supports: Linux and macOS
# ============================================================

ensure_prek() {
    if command -v prek &>/dev/null && prek install --help | grep -Fq -- '--hook-command'; then
        return
    fi

    echo "Installing prek for the current user..."
    (
        installer=$(mktemp)
        trap 'rm -f "$installer"' EXIT
        curl --proto '=https' --tlsv1.2 -fsSL \
            https://github.com/j178/prek/releases/latest/download/prek-installer.sh \
            -o "$installer"
        PREK_INSTALL_DIR="$HOME/.local/bin" PREK_NO_MODIFY_PATH=1 sh "$installer"
    )
    hash -r
    prek --version
}

setup_prek_hook() (
    export PATH="$HOME/.local/bin:$PATH"
    ensure_prek
    cd "$HOME/.config"
    launcher=$(printf 'bash scripts/zed-post-commit.sh %q' "$(command -v prek)")
    hook=$(git rev-parse --git-path hooks/post-commit)
    install_args=(--hook-type post-commit --hook-command "$launcher")
    hooks_path_setting=$(git config --show-scope --get core.hooksPath || true)
    registered_hook_command='"$(git rev-parse --path-format=absolute --git-common-dir)/dotconfig-prek/hooks/post-commit"'
    current_command=$(git config --local --get hook.dotconfig-prek.command || true)

    case "$hooks_path_setting" in
        ''|local$'\t'*|worktree$'\t'*) use_registered_hook=false ;;
        *) use_registered_hook=true ;;
    esac
    if [ "$use_registered_hook" = true ] || [ "$current_command" = "$registered_hook_command" ]; then
        if ! git hook list -h 2>&1 | grep -Fq 'git hook list'; then
            echo "Error: Git 2.54 or newer is required to enable prek alongside the shared hooks directory." >&2
            exit 1
        fi
        hook_git_dir="$(git rev-parse --path-format=absolute --git-common-dir)/dotconfig-prek"
        hook="$hook_git_dir/hooks/post-commit"
        install_args+=(--git-dir "$hook_git_dir")
        use_registered_hook=true
    fi

    if [ ! -x "$hook" ] || ! grep -Fq -- "exec $launcher hook-impl " "$hook"; then
        prek install "${install_args[@]}"
        echo "Installed the prek post-commit hook."
    else
        echo "The prek post-commit hook is already installed."
    fi

    if [ "$use_registered_hook" = true ]; then
        if [ "$current_command" != "$registered_hook_command" ]; then
            git config --local hook.dotconfig-prek.command "$registered_hook_command"
        fi
        if [ "$(git config --local --get hook.dotconfig-prek.event || true)" != post-commit ]; then
            git config --local hook.dotconfig-prek.event post-commit
        fi
    fi
)

apply_zed_settings() {
    if ! command -v python3 &>/dev/null; then
        echo "Error: Python 3 is required to apply shared Zed settings." >&2
        return 1
    fi

    "$HOME/.config/zed/apply_settings.py"
}

if [ "${1:-}" = "--zed-settings" ]; then
    apply_zed_settings
    exit
fi

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

# ---- Apply Zed Settings ----

apply_zed_settings

# ---- Install prek and Set Up the Git Hook ----

setup_prek_hook

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
