#!/usr/bin/env bash
set -euo pipefail

# Override with PACMAN_CACHE_KEEP=1 to retain only one cached package version.
cleanup_failures=0

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
    if "$cmd" "$@"; then
      :
    else
      local status=$?
      echo "❌ Failed (exit $status): ${cmdline% }; continuing cleanup" >&2
      cleanup_failures=$((cleanup_failures + 1))
    fi
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
    echo "❌ Cannot run $cmd: root privileges required, but sudo was not found" >&2
    cleanup_failures=$((cleanup_failures + 1))
  fi
}

cleanup_arch() {
  local keep="$1"
  if command -v paccache >/dev/null 2>&1; then
    echo "ℹ️ Keeping $keep cached versions per package (override with PACMAN_CACHE_KEEP)."
    run_as_root_if_available paccache -r -k "$keep"
    run_as_root_if_available paccache -r -u -k 0
  else
    echo "ℹ️ Install pacman-contrib for version-aware cleanup; falling back to pacman -Sc."
    # Keep pacman's confirmation prompts and cache for installed packages.
    run_as_root_if_available pacman -Sc
  fi

  if (( EUID == 0 )); then
    echo "⚠️ Skipping AUR caches: run this script as a regular user to clean them" >&2
  else
    # Clear all AUR build caches, retaining prompts and leaving pacman's cache alone.
    run_if_available yay -Scc --aur
    run_if_available paru -Scc --aur
  fi
}

cleanup_linux_coredumps() {
  local dump_dir=/var/lib/systemd/coredump
  if [[ -d "$dump_dir" ]]; then
    # Remove completed crash dumps only; keep the directory and other files.
    run_as_root_if_available find "$dump_dir" -xdev -maxdepth 1 \
      -type f -name 'core.*' -print -delete
  else
    echo "⚠️ Skipping: $dump_dir not found" >&2
  fi
}

cleanup_user_caches() {
  local os="$1"
  if (( EUID == 0 )); then
    echo "⚠️ Skipping user caches: run this script as a regular user to clean them" >&2
    return
  fi

  run_if_available npm cache clean --force
  run_if_available yarn cache clean
  run_if_available pnpm store prune

  if [[ "$os" == linux || "$os" == arch ]]; then
    local baloo_cmd
    if command -v balooctl6 >/dev/null 2>&1; then
      baloo_cmd=balooctl6
    elif command -v balooctl >/dev/null 2>&1; then
      baloo_cmd=balooctl
    else
      echo "⚠️ Skipping Baloo index: balooctl6/balooctl not found" >&2
      return
    fi

    # purge stops the indexer before deleting its database and restarts it if running.
    echo "ℹ️ Clearing the Baloo index; enabled indexing will rebuild it afterward."
    run_if_available "$baloo_cmd" purge
  fi
}

main() {
  local os keep="${PACMAN_CACHE_KEEP:-2}"
  cleanup_failures=0
  os="$(detect_os)"
  echo "🖥️ Detected OS: $os"

  if [[ "$os" == arch && ! "$keep" =~ ^[1-9][0-9]*$ ]]; then
    echo "❌ PACMAN_CACHE_KEEP must be a positive integer (default: 2)" >&2
    return 1
  fi

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
    cleanup_arch "$keep"
  fi

  cleanup_user_caches "$os"

  if [[ "$os" == linux || "$os" == arch ]]; then
    cleanup_linux_coredumps
  fi

  # Cleanup docker images
  run_if_available docker image prune -a

  if (( cleanup_failures > 0 )); then
    echo "❌ Cleanup finished with $cleanup_failures failed command(s); see errors above." >&2
    return 1
  fi
  echo "✅ Cache cleanup finished."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
