#!/usr/bin/env bash
show_power_menu() {
  local menu_options="󰤄  Sleep
  Lock
  Logout
  Reboot
⏻  Power Off"

  choice=$(printf "$menu_options" | wofi --dmenu --insensitive --cache-file /dev/null)

  case "$choice" in
  "⏻  Power Off") systemctl poweroff ;;
  "  Reboot") systemctl reboot ;;
  "  Logout") hyprctl dispatch exit ;;
  "  Lock") hyprlock ;;
  "󰤄  Sleep") systemctl suspend ;;
  esac
}

show_power_menu
