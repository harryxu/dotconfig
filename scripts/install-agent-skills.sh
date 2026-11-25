#!/usr/bin/env bash
# Global installs for the current user on Codex and Antigravity by default:
#   - Humanizer writing skill (https://github.com/blader/humanizer).
#   - Matt Pocock's engineering and productivity skills (https://github.com/mattpocock/skills).
#   - Addy Osmani's software engineering skills (https://github.com/addyosmani/agent-skills).
#   - RTK command output filter (https://github.com/rtk-ai/rtk), installed if needed
#     and configured for the selected agents.
# The Matt Pocock and Addy Osmani collections use native plugins where supported.
# The Skills CLI fallback installs every skill it discovers in each collection.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install-agent-skills.sh [--agent all|codex|antigravity] [--dry-run]

Install Humanizer, Matt Pocock's skills, Addy Osmani's agent skills, and
RTK for the current user. The default target is both agents.

Requires Git and Node.js 22.20+ with npx. Native plugins are used when the
corresponding agent CLI supports them. Re-running may replace skill copies.
--dry-run prints the plan and assumes any CLI on PATH supports plugins.
EOF
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

agent=all
dry_run=0
while (( $# )); do
  case "$1" in
    --agent)
      (( $# >= 2 )) || fail '--agent requires all, codex, or antigravity.'
      agent=$2
      shift
      ;;
    --dry-run) dry_run=1 ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown option: $1. See --help." ;;
  esac
  shift
done

case "$agent" in
  all|codex|antigravity) ;;
  *) fail "Unknown agent: $agent. Use all, codex, or antigravity." ;;
esac

initial_path=$PATH
rtk_install_dir=${RTK_INSTALL_DIR:-"$HOME/.local/bin"}
export PATH="$PATH:$HOME/.local/bin:$rtk_install_dir"

run() {
  printf '  +'
  printf ' %q' "$@"
  printf '\n'
  if (( ! dry_run )); then
    "$@"
  fi
}

has_plugin_cli() {
  command -v "$1" >/dev/null &&
    { (( dry_run )) || "$@" >/dev/null 2>&1; }
}

install_skills() {
  local repo=$1 target=$2 selection=${3:-'*'}
  # Direct copies keep Antigravity's skills out of the shared Codex directory.
  # JSON mode reports partial installation failures with a nonzero exit status.
  run npx --yes skills@latest add "$repo" --global --agent "$target" \
    --skill "$selection" --copy --yes --json
}

install_codex_plugin() {
  run codex plugin marketplace add "$1"
  run codex plugin add "$2"
}

install_mattpocock_antigravity() {
  if run agy plugin install https://github.com/mattpocock/skills; then
    if (( dry_run )); then
      return
    fi

    # Older agy releases could report success while skipping nested skills.
    local setup_skill_loaded
    setup_skill_loaded=$(agy plugin list --json | node -e '
      const { readFileSync } = require("node:fs");
      const result = JSON.parse(readFileSync(0, "utf8"));
      const plugins = Array.isArray(result) ? result : result.plugins;
      const plugin = plugins.find(({ name }) => name === "mattpocock-skills");
      console.log(plugin?.skills?.includes("setup-matt-pocock-skills") ?? false);
    ')
    if [[ $setup_skill_loaded == true ]]; then
      return
    fi
  fi

  printf 'Matt Pocock skills were unavailable through agy. Falling back to Skills CLI.\n'
  install_skills mattpocock/skills antigravity
}

install_rtk() (
  if command -v rtk >/dev/null; then
    return
  fi
  if command -v brew >/dev/null; then
    run brew install rtk
    return
  fi

  local url=https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh
  if (( dry_run )); then
    printf '  + Download %s and run it with sh\n' "$url"
    return
  fi

  local installer
  installer=$(mktemp "${TMPDIR:-/tmp}/install-rtk.XXXXXX")
  trap 'rm -f -- "$installer"' EXIT
  run curl -fsSL "$url" -o "$installer"
  run sh "$installer"
)

if (( ! dry_run )); then
  for dependency in node npx git; do
    command -v "$dependency" >/dev/null || fail "$dependency is required."
  done
fi

if [[ $agent == all || $agent == codex ]]; then
  printf '\nInstalling Codex skills\n'
  install_skills blader/humanizer codex humanizer
  if has_plugin_cli codex plugin add --help; then
    install_codex_plugin mattpocock/skills mattpocock-skills@mattpocock
    install_codex_plugin addyosmani/agent-skills agent-skills@agent-skills
  else
    install_skills mattpocock/skills codex
    install_skills addyosmani/agent-skills codex
  fi
fi

if [[ $agent == all || $agent == antigravity ]]; then
  printf '\nInstalling Antigravity skills\n'
  install_skills blader/humanizer antigravity humanizer
  if has_plugin_cli agy plugin help; then
    install_mattpocock_antigravity
    run agy plugin install https://github.com/addyosmani/agent-skills.git
  else
    install_skills mattpocock/skills antigravity
    install_skills addyosmani/agent-skills antigravity
  fi
fi

printf '\nConfiguring RTK\n'
install_rtk
if (( ! dry_run )); then
  command -v rtk >/dev/null || fail 'RTK is unavailable on PATH after installation.'
fi
if [[ $agent == all || $agent == codex ]]; then
  run rtk init -g --codex
fi
if [[ $agent == all || $agent == antigravity ]]; then
  run rtk init -g --agent antigravity
fi

if (( ! dry_run )); then
  if ! (PATH=$initial_path; command -v rtk >/dev/null); then
    printf '\nAdd the RTK directory to your shell profile before restarting.\n'
    printf '  export PATH=%q:"$PATH"\n' "$(dirname "$(command -v rtk)")"
  fi
  printf '\nInstallation complete. Restart the target agents to load the new configuration.\n'
fi
