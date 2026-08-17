#!/usr/bin/env bash
set -euo pipefail

# Helper: run a command only if it's available on the system
run_if_available() {
  local cmd="$1"
  shift
  local args=("$@")
  if command -v "$cmd" >/dev/null 2>&1; then
    # Build a safely quoted representation of the command for display
    local cmdline
    printf -v cmdline '%q ' "$cmd" "${args[@]:-}"
    echo "🚀 Running: ${cmdline% }"
    "$cmd" "${args[@]:-}"
    echo
  else
    echo "⚠️ Skipping: $cmd not found" >&2
  fi
}

# Cleanup Homebrew cache
run_if_available brew cleanup --prune=all

# Cleanup yarn cache
run_if_available yarn cache clean

# Prune pnpm store
run_if_available pnpm store prune

# Cleanup docker images
run_if_available docker image prune -a
