#!/usr/bin/env python3
import json
from pathlib import Path
import sys

from apply_settings import decode_settings, jsonc_to_json, read_existing, write_settings


# Exclude these top-level keys from the Git-tracked settings.
LOCAL_ONLY_KEYS = {
    "agent",
    "collaboration_panel",
    "context_servers",
    "git_panel",
    "outline_panel",
    "project_panel",
    "ssh_connections",
}


def export_settings(directory):
    local_text = (directory / "settings.json").read_text(encoding="utf-8")
    local = decode_settings(jsonc_to_json(local_text))
    shared = {key: value for key, value in local.items() if key not in LOCAL_ONLY_KEYS}
    body = json.dumps(shared, ensure_ascii=False, indent=2, allow_nan=False)
    header = "{\n  // Shared preferences applied by install.sh.\n"
    updated = (header + body[1:].lstrip("\n") + "\n").encode("utf-8")

    destination = (directory / "settings.shared.jsonc").resolve()
    original = read_existing(destination)
    if updated == original:
        print("Zed shared settings are already up to date.")
        return

    write_settings(destination, original, updated)
    print("Exported Zed settings to settings.shared.jsonc.")


if __name__ == "__main__":
    try:
        export_settings(Path(__file__).resolve().parent)
    except (OSError, RuntimeError, ValueError) as error:
        sys.exit(f"Error exporting shared Zed settings: {error}")
