#!/bin/bash

# Get cliphist history
cliphist_output=$(cliphist list)

# Define custom commands as associative array
# Key: display text, Value: command to execute
declare -A custom_commands
custom_commands["	> Wipe"]="cliphist wipe"
custom_commands["	> Compact"]="cliphist compact"

# Function to check if item is custom command
is_custom_command() {
    local item="$1"
    [[ -v custom_commands["$item"] ]]
}

# Function to show main menu
show_main_menu() {
    local options="$cliphist_output"
    for cmd_display in "${!custom_commands[@]}"; do
        options=$(printf "%s\n%s" "$options" "$cmd_display")
    done
    
    echo "$options" | rofi \
        -dmenu \
        -i \
        -display-columns 2 \
        -p "cliphist" \
        -theme ~/.config/rofi/themes/rounded-nord-dark.rasi \
        -me-select-entry '' \
        -me-accept-entry MousePrimary \
        -hover-select \
        -kb-custom-1 "Alt+Return"
    
    return $?
}

# Function to show submenu for history items
show_submenu() {
    local selected="$1"
    local options=$(printf "%s\nCopy and Delete\nDelete" "$selected")
    
    # Add custom commands to submenu
    for cmd_display in "${!custom_commands[@]}"; do
        options=$(printf "%s\n%s" "$options" "$cmd_display")
    done
    
    echo "$options" | rofi \
        -dmenu \
        -i \
        -p "cliphist" \
        -theme ~/.config/rofi/themes/rounded-nord-dark.rasi \
        -me-select-entry '' \
        -me-accept-entry MousePrimary \
        -hover-select
    
    return $?
}

# Main menu loop
while true; do
    selected=$(show_main_menu)
    exit_code=$?
    
    # If user cancels (press Esc or close window)
    if [ $exit_code -eq 1 ] || [ -z "$selected" ]; then
        exit 0
    fi
    
    # Check if selected item is a custom command
    if is_custom_command "$selected"; then
        eval "${custom_commands[$selected]}"
        exit 0
    fi
    
    # If Alt+Return was pressed (exit code 10), show submenu
    if [ $exit_code -eq 10 ]; then
        submenu_choice=$(show_submenu "$selected")
        submenu_exit=$?
        
        # If user cancels submenu
        if [ $submenu_exit -eq 1 ] || [ -z "$submenu_choice" ]; then
            continue
        fi
        
        # Check if submenu choice is a custom command
        if is_custom_command "$submenu_choice"; then
            eval "${custom_commands[$submenu_choice]}"
            exit 0
        fi
        
        # Execute submenu command based on choice
        if [ "$submenu_choice" = "$selected" ]; then
            # Copy selected item to clipboard
            echo "$selected" | cliphist decode | wl-copy
        elif [ "$submenu_choice" = "Copy and Delete" ]; then
            # Copy to clipboard and delete from history
            echo "$selected" | cliphist decode | wl-copy
            echo "$selected" | cliphist delete
        elif [ "$submenu_choice" = "Delete" ]; then
            # Delete from history without copying
            echo "$selected" | cliphist delete
        fi
        
        exit 0
    else
        # Normal Enter key (exit code 0) - copy history item to clipboard
        echo "$selected" | cliphist decode | wl-copy
        exit 0
    fi
done