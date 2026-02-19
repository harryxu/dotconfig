#!/usr/bin/env bash

# Plugin manager script for Neovim
# Manages symlinks between lua/plugins-available/ and lua/plugins/

set -euo pipefail

# Resolve the directory where this script resides
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

AVAILABLE_DIR="${SCRIPT_DIR}/lua/plugins-available"
ENABLED_DIR="${SCRIPT_DIR}/lua/plugins"

# ---------------------------------------------------------------------------
# Helper: print usage information
# ---------------------------------------------------------------------------
usage() {
    cat <<EOF
Usage: $(basename "$0") <command> [options]

Commands:
  enable <plugin>   Enable a plugin by creating a symlink from
                    lua/plugins-available/<plugin>.lua -> lua/plugins/<plugin>.lua
  enable --all      Enable all plugins found in lua/plugins-available/
  disable <plugin>  Disable a plugin by removing lua/plugins/<plugin>.lua
  disable --all     Disable all plugins that match files in lua/plugins-available/
  list              List all available plugins in lua/plugins-available/
  mini              Enter mini mode (create mini.mode flag file, Neovim skips plugins)
  unmini            Exit mini mode (remove mini.mode flag file)

Examples:
  $(basename "$0") enable mason
  $(basename "$0") enable --all
  $(basename "$0") disable mason
  $(basename "$0") disable --all
  $(basename "$0") list
  $(basename "$0") mini
  $(basename "$0") unmini
EOF
}

# ---------------------------------------------------------------------------
# Command: enable <plugin> | --all
# ---------------------------------------------------------------------------
cmd_enable() {
    local target="$1"

    if [[ "$target" == "--all" ]]; then
        local count=0
        for src in "${AVAILABLE_DIR}"/*.lua; do
            [[ -e "$src" ]] || { echo "No plugins found in ${AVAILABLE_DIR}."; return 1; }
            local filename
            filename="$(basename "$src")"
            local dst="${ENABLED_DIR}/${filename}"
            if [[ -L "$dst" ]]; then
                echo "[skip]    ${filename} (already enabled)"
            elif [[ -e "$dst" ]]; then
                echo "[skip]    ${filename} (a non-symlink file already exists at destination)"
            else
                ln -s "${src}" "${dst}"
                echo "[enabled] ${filename}"
                count=$((count + 1))
            fi
        done
        echo ""
        echo "Done. ${count} plugin(s) newly enabled."
        return 0
    fi

    # Single plugin
    local plugin_name="${target%.lua}"  # strip .lua suffix if provided
    local src="${AVAILABLE_DIR}/${plugin_name}.lua"
    local dst="${ENABLED_DIR}/${plugin_name}.lua"

    if [[ ! -f "$src" ]]; then
        echo "Error: Plugin '${plugin_name}' not found in ${AVAILABLE_DIR}." >&2
        exit 1
    fi

    if [[ -L "$dst" ]]; then
        echo "Plugin '${plugin_name}' is already enabled."
        exit 0
    elif [[ -e "$dst" ]]; then
        echo "Error: '${dst}' exists but is not a symlink. Remove it manually if you want to enable the plugin." >&2
        exit 1
    fi

    ln -s "${src}" "${dst}"
    echo "Plugin '${plugin_name}' enabled."
}

# ---------------------------------------------------------------------------
# Command: disable <plugin> | --all
# ---------------------------------------------------------------------------
cmd_disable() {
    local target="$1"

    if [[ "$target" == "--all" ]]; then
        local count=0
        for src in "${AVAILABLE_DIR}"/*.lua; do
            [[ -e "$src" ]] || { echo "No plugins found in ${AVAILABLE_DIR}."; return 1; }
            local filename
            filename="$(basename "$src")"
            local dst="${ENABLED_DIR}/${filename}"
            if [[ -e "$dst" || -L "$dst" ]]; then
                rm "${dst}"
                echo "[disabled] ${filename}"
                count=$((count + 1))
            else
                echo "[skip]     ${filename} (not enabled)"
            fi
        done
        echo ""
        echo "Done. ${count} plugin(s) disabled."
        return 0
    fi

    local plugin_name="${target%.lua}"  # strip .lua suffix if provided
    local dst="${ENABLED_DIR}/${plugin_name}.lua"

    if [[ ! -e "$dst" && ! -L "$dst" ]]; then
        echo "Plugin '${plugin_name}' is not currently enabled (file not found: ${dst})."
        exit 0
    fi

    rm "${dst}"
    echo "Plugin '${plugin_name}' disabled."
}

# ---------------------------------------------------------------------------
# Command: mini / unmini
# ---------------------------------------------------------------------------
cmd_mini() {
    local flag="${SCRIPT_DIR}/mini.mode"
    if [[ -f "$flag" ]]; then
        echo "Already in mini mode (${flag} exists)."
    else
        touch "${flag}"
        echo "Mini mode enabled. Restart Neovim to take effect."
    fi
}

cmd_unmini() {
    local flag="${SCRIPT_DIR}/mini.mode"
    if [[ ! -f "$flag" ]]; then
        echo "Not in mini mode (${flag} does not exist)."
    else
        rm "${flag}"
        echo "Mini mode disabled. Restart Neovim to take effect."
    fi
}

# ---------------------------------------------------------------------------
# Command: list
# ---------------------------------------------------------------------------
cmd_list() {
    echo "Available plugins (in lua/plugins-available/):"
    echo ""
    local found=0
    for src in "${AVAILABLE_DIR}"/*.lua; do
        [[ -e "$src" ]] || { echo "  (none)"; return 0; }
        local filename
        filename="$(basename "$src")"
        local plugin_name="${filename%.lua}"
        local dst="${ENABLED_DIR}/${filename}"
        local status
        if [[ -L "$dst" ]]; then
            status="enabled"
        elif [[ -e "$dst" ]]; then
            status="enabled (non-symlink)"
        else
            status="disabled"
        fi
        printf "  %-30s [%s]\n" "${plugin_name}" "${status}"
        found=$((found + 1))
    done
    echo ""
    echo "Total: ${found} plugin(s)"
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
if [[ $# -eq 0 ]]; then
    usage
    exit 0
fi

COMMAND="$1"
shift

case "$COMMAND" in
    enable)
        if [[ $# -eq 0 ]]; then
            echo "Error: 'enable' requires a plugin name or '--all'." >&2
            echo ""
            usage
            exit 1
        fi
        cmd_enable "$1"
        ;;
    disable)
        if [[ $# -eq 0 ]]; then
            echo "Error: 'disable' requires a plugin name." >&2
            echo ""
            usage
            exit 1
        fi
        cmd_disable "$1"
        ;;
    list)
        cmd_list
        ;;
    mini)
        cmd_mini
        ;;
    unmini)
        cmd_unmini
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo "Error: Unknown command '${COMMAND}'." >&2
        echo ""
        usage
        exit 1
        ;;
esac
