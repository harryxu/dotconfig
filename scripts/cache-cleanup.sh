#!/usr/bin/env bash
set -euo pipefail

# Detect Arch and its derivatives from distribution metadata, not CPU architecture.
detect_os() {
  case "$(uname -s)" in
    Darwin)
      echo macos
      ;;
    Linux)
      local ID='' ID_LIKE='' release_file
      for release_file in /etc/os-release /usr/lib/os-release; do
        if [[ -r "$release_file" ]]; then
          # shellcheck disable=SC1090
          . "$release_file"
          break
        fi
      done

      case " $ID $ID_LIKE " in
        *" arch "*) echo arch ;;
        *) echo linux ;;
      esac
      ;;
    *)
      echo unknown
      ;;
  esac
}

# Helper: run a command only if it's available on the system
run_if_available() {
  local cmd="$1"
  shift
  if command -v "$cmd" >/dev/null 2>&1; then
    # Build a safely quoted representation of the command for display
    local cmdline
    printf -v cmdline '%q ' "$cmd" "$@"
    echo "🚀 Running: ${cmdline% }"
    "$cmd" "$@"
    echo
  else
    echo "⚠️ Skipping: $cmd not found" >&2
  fi
}

# Only elevate system cache cleanup; keep user cache commands unprivileged.
run_as_root_if_available() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "⚠️ Skipping: $cmd not found" >&2
  elif (( EUID == 0 )); then
    run_if_available "$@"
  elif command -v sudo >/dev/null 2>&1; then
    run_if_available sudo "$@"
  else
    echo "⚠️ Skipping: $cmd requires root privileges, but sudo was not found" >&2
  fi
}

cleanup_arch() {
  if command -v paccache >/dev/null 2>&1; then
    # Keep the latest three cached versions, then remove uninstalled packages.
    run_as_root_if_available paccache -r -k 3
    run_as_root_if_available paccache -r -u -k 0
  else
    echo "ℹ️ Install pacman-contrib for version-aware cleanup; falling back to pacman -Sc."
    # Keep pacman's confirmation prompts and cache for installed packages.
    run_as_root_if_available pacman -Sc
  fi

  if (( EUID == 0 )); then
    echo "⚠️ Skipping AUR caches: run this script as a regular user to clean them" >&2
  else
    # Clean each helper's AUR cache without pruning the pacman cache again.
    run_if_available yay -Sc --aur
    run_if_available paru -Sc --aur
  fi
}

main() {
  local os
  os="$(detect_os)"
  echo "🖥️ Detected OS: $os"

  case "$os" in
    macos|linux|arch)
      # Homebrew is available on both macOS and Linux.
      run_if_available brew cleanup --prune=all
      ;;
    *)
      echo "⚠️ Unknown OS; skipping system-specific cache cleanup" >&2
      ;;
  esac

  if [[ "$os" == arch ]]; then
    cleanup_arch
  fi

  # Cleanup yarn cache
  run_if_available yarn cache clean

  # Prune pnpm store
  run_if_available pnpm store prune

  # Cleanup docker images
  run_if_available docker image prune -a
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
