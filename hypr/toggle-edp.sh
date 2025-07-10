#!/bin/sh
# This script toggles the internal laptop display (eDP-1) on or off in Hyprland.

disabled=$(hyprctl monitors | grep -A20 "Monitor eDP-1" | grep "disabled:" | awk '{print $2}')

if [[ "$disabled" == "false" ]]; then
  hyprctl keyword monitor "eDP-1,disable"
else
  hyprctl keyword monitor "eDP-1,preferred,auto,1"
fi
