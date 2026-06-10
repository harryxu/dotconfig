#!/bin/bash

# This script generates the 'auto_install_extensions' JSON object.
#
# DEFAULT BEHAVIOR (no flags):
#   - Prints the generated JSON to the console for preview.
#   - DOES NOT modify any files.
#
# UPDATE BEHAVIOR (-u flag):
#   - Updates your settings.json file by merging the generated object.
#   - This mode ASSUMES your settings.json is a valid JSON file without comments.

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error.
set -u
# Pipes will fail if any command in the pipe fails.
set -o pipefail

# --- Configuration ---
ZED_SETTINGS_FILE="$HOME/.config/zed/settings.json"
EXTENSIONS_DIR=""
UPDATE_FILE=false

# --- Functions ---
# Print an error message and exit.
die() {
  echo "Error: $1" >&2
  exit 1
}

# --- Main Logic ---

# 1. Parse command line arguments to check for the -u flag.
if [[ "${1-}" == "-u" ]]; then
  UPDATE_FILE=true
fi

# 2. Check for 'jq' dependency.
if ! command -v jq &>/dev/null; then
  die "'jq' is not installed. Please install it to continue (e.g., 'brew install jq')."
fi

# 3. Determine OS-specific extensions directory.
case "$(uname -s)" in
Darwin)
  EXTENSIONS_DIR="$HOME/Library/Application Support/Zed/extensions/installed"
  ;;
Linux)
  if [[ -n "${XDG_DATA_HOME-}" ]]; then
    EXTENSIONS_DIR="$XDG_DATA_HOME/zed/extensions/installed"
  else
    EXTENSIONS_DIR="$HOME/.local/share/zed/extensions/installed"
  fi
  ;;
*)
  die "Unsupported OS: $(uname -s)"
  ;;
esac

# 4. Verify that the extensions directory exists.
if [ ! -d "$EXTENSIONS_DIR" ]; then
  die "Zed extensions directory not found at: $EXTENSIONS_DIR"
fi

# 5. List all subdirectories to get extension IDs.
echo "# Scanning for installed extension directories..." >&2
extension_ids=()

while IFS= read -r -d '' dir; do
  id=$(basename "$dir")
  extension_ids+=("$id")
done < <(find "$EXTENSIONS_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

if [ ${#extension_ids[@]} -eq 0 ]; then
  echo "# No extension directories found. Nothing to do." >&2
  exit 0
fi

# 6. Generate the JSON object using jq.
IFS=$'\n' sorted_ids=($(sort <<<"${extension_ids[*]}"))
unset IFS

generated_json=$(
  printf '%s\n' "${sorted_ids[@]}" |
    jq -R -s '
        split("\n") | 
        map(select(length > 0)) | 
        map({key: ., value: true}) | 
        from_entries | 
        {auto_install_extensions: .}
    '
)

# 7. ALWAYS print the generated JSON object to standard output.
echo "$generated_json"

# 8. Conditionally update the file if the -u flag was provided.
if [ "$UPDATE_FILE" = true ]; then
  echo "# Updating settings file (-u flag detected)..." >&2

  if [ ! -f "$ZED_SETTINGS_FILE" ]; then
    # If file doesn't exist, just create it with the generated content.
    echo "$generated_json" >"$ZED_SETTINGS_FILE"
    echo "# ✅ Success! Created and updated settings file." >&2
  else
    # If file exists, merge the new object into it.
    # This will add or overwrite the 'auto_install_extensions' key.
    tmp_file=$(mktemp)

    # 'jq -s' reads both files into an array, then we merge them.
    # The second object's keys (our generated ones) will overwrite the first.
    if jq -s '.[0] * .[1]' "$ZED_SETTINGS_FILE" <(echo "$generated_json") >"$tmp_file"; then
      mv "$tmp_file" "$ZED_SETTINGS_FILE"
      echo "# ✅ Success! Settings file updated." >&2
    else
      rm -f "$tmp_file"
      die "Failed to update JSON file. Please ensure it is a valid JSON."
    fi
  fi
else
  # If not updating, print a helpful tip.
  echo >&2 # Add a newline for better readability
  echo "# To apply these settings, run the script again with the -u flag:" >&2
  echo "#   $0 -u" >&2
fi
