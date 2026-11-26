#!/usr/bin/env python3
import json
import os
from pathlib import Path
import re
import stat
import sys
import tempfile


JSON_STRING = r'"(?:\\.|[^"\\])*"'
COMMENTS = re.compile(JSON_STRING + r'|//[^\r\n]*|/\*[\s\S]*?\*/')
# Match a trailing comma only after the end of a value.
TRAILING_COMMAS = re.compile(JSON_STRING + r'|(?<=[0-9el"\]}])[ \t\r\n]*,(?=[ \t\r\n]*[}\]])')
WHITESPACE = re.compile(r'[ \t\r\n]*')
DECODER = json.JSONDecoder()


def jsonc_to_json(text):
    # Keep offsets stable so that edits leave local comments and formatting intact.
    def mask(match):
        token = match[0]
        return token if token.startswith('"') else re.sub(r'[^\r\n]', ' ', token)

    return TRAILING_COMMAS.sub(mask, COMMENTS.sub(mask, text))


def decode_settings(text):
    settings = DECODER.decode(text)
    if not isinstance(settings, dict):
        raise ValueError("Zed settings must contain a JSON object.")
    return settings


def merge_settings(text, shared):
    normalized = jsonc_to_json(text)
    decode_settings(normalized)
    edits = []
    newline = "\r\n" if "\r\n" in text else "\n"

    def skip_space(offset):
        return WHITESPACE.match(normalized, offset).end()

    def collect_edits(start, settings, depth):
        members = {}
        position = skip_space(start + 1)
        while normalized[position] != "}":
            key, key_end = DECODER.raw_decode(normalized, position)
            value_start = skip_space(skip_space(key_end) + 1)
            value, value_end = DECODER.raw_decode(normalized, value_start)
            members[key] = (value_start, value_end, value)
            position = skip_space(value_end)
            if normalized[position] == ",":
                position = skip_space(position + 1)

        indent = "  " * (depth + 1)
        additions = []
        for key, value in settings.items():
            rendered = json.dumps(value, ensure_ascii=False, indent=2)
            rendered = rendered.replace("\n", newline + indent)
            if key not in members:
                additions.append(f"{indent}{json.dumps(key, ensure_ascii=False)}: {rendered}")
                continue

            value_start, value_end, current = members[key]
            if isinstance(current, dict) and isinstance(value, dict):
                collect_edits(value_start, value, depth + 1)
            elif json.dumps(current, sort_keys=True) != json.dumps(value, sort_keys=True):
                edits.append((value_start, value_end, rendered))

        if additions:
            insertion = newline + ("," + newline).join(additions)
            if members:
                insertion += ","
            if text[start + 1:start + 2] not in ("\r", "\n"):
                insertion += newline + (indent if members else "  " * depth)
            edits.append((start + 1, start + 1, insertion))

    collect_edits(skip_space(0), shared, 0)
    for start, end, replacement in sorted(edits, reverse=True):
        text = text[:start] + replacement + text[end:]
    return text


def read_existing(path):
    try:
        return path.read_bytes()
    except FileNotFoundError:
        return None


def write_settings(destination, original, updated):
    output = tempfile.NamedTemporaryFile(dir=destination.parent, delete=False)
    temporary = Path(output.name)
    try:
        with output:
            output.write(updated)
        if original is None:
            os.link(temporary, destination)
        else:
            temporary.chmod(stat.S_IMODE(destination.stat().st_mode))
            if read_existing(destination) != original:
                raise RuntimeError("Zed settings changed while applying updates. Please retry.")
            temporary.replace(destination)
    finally:
        if temporary.exists():
            temporary.unlink()


def apply_settings(directory):
    shared_bytes = (directory / "settings.shared.jsonc").read_bytes()
    shared = decode_settings(jsonc_to_json(shared_bytes.decode("utf-8")))
    destination = (directory / "settings.json").resolve()
    original = read_existing(destination)
    updated = shared_bytes if original is None else merge_settings(original.decode("utf-8"), shared).encode("utf-8")
    if updated == original:
        print("Zed shared settings are already up to date.")
        return

    write_settings(destination, original, updated)
    print("Applied shared Zed settings.")


if __name__ == "__main__":
    try:
        apply_settings(Path(__file__).resolve().parent)
    except (OSError, RuntimeError, ValueError) as error:
        sys.exit(f"Error applying shared Zed settings: {error}")
