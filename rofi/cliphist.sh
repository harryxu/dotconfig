#!/bin/bash

# Get cliphist history
cliphist_output=$(cliphist list)

# Define custom commands as associative array
# Key: display text, Value: command to execute
declare -A custom_commands
custom_commands["	> Wipe"]="cliphist wipe"
custom_commands["	> Compact"]="cliphist compact"

# Combine history with custom operations
options="$cliphist_output"
for cmd_display in "${!custom_commands[@]}"; do
    options=$(printf "%s\n%s" "$options" "$cmd_display")
done

# Display options through rofi and get user selection
selected=$(echo "$options" | rofi \
    -dmenu \
    -i \
    -display-columns 2 \
    -p "cliphist" \
    -theme ~/.config/rofi/themes/rounded-nord-dark.rasi \
    -me-select-entry '' \
    -me-accept-entry MousePrimary \
    -hover-select)

# If user cancels selection (press Esc or close window)
if [ -z "$selected" ]; then
    exit 0
fi

# Check if selected item is a custom command
if [[ -v custom_commands["$selected"] ]]; then
    eval "${custom_commands[$selected]}"
else
    # Handle history item selection: decode and copy to clipboard
    echo "$selected" | cliphist decode | wl-copy
fi
