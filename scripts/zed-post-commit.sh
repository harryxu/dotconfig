#!/usr/bin/env bash

set -euo pipefail

settings_file=zed/settings.shared.jsonc

if [[ ${1:-} == --commit ]]; then
    if [[ ${DOTCONFIG_ZED_EXPORT_PREPARED:-} != 1 || ${DOTCONFIG_ZED_AUTO_COMMIT:-} == 1 ]]; then
        exit 0
    fi
    if git diff --cached --quiet -- "$settings_file"; then
        exit 0
    fi
    DOTCONFIG_ZED_AUTO_COMMIT=1 git commit --only -m 'zed: Update settings.shared.jsonc' -- "$settings_file"
    printf '%s was updated and committed.\n' "$settings_file"
    exit 0
fi

prek_command=$1
shift
if [[ ${DOTCONFIG_ZED_AUTO_COMMIT:-} == 1 ]]; then
    if [[ ${2:-} == --hook-dir=* && -x "${2#--hook-dir=}/post-commit.legacy" ]]; then
        PREK_SKIP="${PREK_SKIP:+$PREK_SKIP,}zed-settings-export" exec "$prek_command" "$@"
    fi
    exit 0
fi

# Stage the export before prek runs so its stash cannot hide edits to the shared file.
./zed/export_settings.py >/dev/null
changes=$(git status --porcelain=v1 -- "$settings_file")
if [[ -n $changes ]]; then
    git add -- "$settings_file"
fi

DOTCONFIG_ZED_EXPORT_PREPARED=1 exec "$prek_command" "$@"
