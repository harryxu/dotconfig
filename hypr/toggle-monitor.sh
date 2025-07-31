#!/bin/sh
# This script toggles or sets a monitor state in Hyprland.
# Usage examples:
#   ./toggle-monitor --m="eDP-1"
#   ./toggle-monitor --m="eDP-1" on
#   ./toggle-monitor --m="eDP-1" off
#   ./toggle-monitor --m="eDP-1" --dep="HDMI-A-2" off

monitor=""
dependent=""
action=""

# Parse arguments
for arg in "$@"; do
  case $arg in
  --m=*)
    monitor="${arg#*=}"
    ;;
  --dep=*)
    dependent="${arg#*=}"
    ;;
  on | off)
    action="$arg"
    ;;
  *)
    echo "Unknown argument: $arg"
    echo "Usage: $0 --m=\"eDP-1\" [--dep=\"HDMI-A-2\"] [on|off]"
    exit 1
    ;;
  esac
done

# Check monitor name
if [ -z "$monitor" ]; then
  echo "Error: Target monitor name not provided."
  echo "Usage: $0 --m=\"eDP-1\" [--dep=\"HDMI-A-2\"] [on|off]"
  exit 1
fi

# Function: Check if monitor is enabled
is_monitor_enabled() {
  mon="$1"
  state=$(hyprctl monitors | grep -A20 "Monitor $mon" | grep "disabled:" | awk '{print $2}')
  [ "$state" = "false" ]
}

# Function: Toggle monitor on/off based on current state
toggle_monitor() {
  if is_monitor_enabled "$monitor"; then
    hyprctl keyword monitor "$monitor,disable"
  else
    hyprctl keyword monitor "$monitor,preferred,auto,1"
  fi
}

# Main logic
case "$action" in
on)
  hyprctl keyword monitor "$monitor,preferred,auto,1"
  ;;
off)
  if [ -n "$dependent" ]; then
    if is_monitor_enabled "$dependent"; then
      hyprctl keyword monitor "$monitor,disable"
    else
      echo "Dependency monitor '$dependent' is not enabled. '$monitor' not disabled."
    fi
  else
    hyprctl keyword monitor "$monitor,disable"
  fi
  ;;
"")
  toggle_monitor
  ;;
*)
  echo "Invalid action: $action"
  echo "Usage: $0 --m=\"eDP-1\" [--dep=\"HDMI-A-2\"] [on|off]"
  exit 1
  ;;
esac
