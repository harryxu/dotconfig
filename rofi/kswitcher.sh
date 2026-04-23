#!/bin/bash

# Detect kdotool binary location
if command -v kdotool &>/dev/null; then
    KDOTOOL="kdotool"
elif [ -x "$HOME/.cargo/bin/kdotool" ]; then
    KDOTOOL="$HOME/.cargo/bin/kdotool"
else
    echo "Error: kdotool not found. Please install it first (cargo install kdotool)" >&2
    exit 1
fi

# Retrieve internal IDs of all windows
WINDOW_IDS=$($KDOTOOL search "")

WINDOW_LIST=""

# Iterate over IDs to get each window's class (app name) and title
for id in $WINDOW_IDS; do
    # Get the application class name (e.g. firefox, kitty)
    class_name=$($KDOTOOL getwindowclassname "$id")
    # Get the full window title
    title=$($KDOTOOL getwindowname "$id")

    # Skip the desktop itself and windows with empty titles
    if [ -n "$title" ] && [ "$class_name" != "plasmashell" ]; then
        # Format: prepend the ID, followed by the app class and title
        # Example: 12345678 [kitty] ~/Projects/vpodcasts
        WINDOW_LIST="$WINDOW_LIST$id [$class_name] $title\n"
    fi
done

# Exit early if no windows were found
if [ -z "$WINDOW_LIST" ]; then
    exit 0
fi

# Pipe the window list into rofi's dmenu mode (-i for case-insensitive matching)
# echo -e interprets escape sequences so newlines are rendered correctly
SELECTED=$(echo -e -n "$WINDOW_LIST" | rofi -dmenu -i -p "Switch to")

# Only proceed if the user made a selection (i.e. did not press ESC)
if [ -n "$SELECTED" ]; then
    # Extract the window ID from the first column of the selected entry
    SELECTED_ID=$(echo "$SELECTED" | awk '{print $1}')

    # Tell KWin to activate and focus the selected window
    $KDOTOOL windowactivate "$SELECTED_ID"
fi


# TODO: https://github.com/davatorium/rofi/issues/38
