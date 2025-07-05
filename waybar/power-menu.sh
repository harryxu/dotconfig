#!/usr/bin/env bash

choice=$(printf "⏻  Power Off\n  Reboot\n  Logout\n  Lock" | wofi --dmenu --insensitive --cache-file /dev/null)

case "$choice" in
"⏻  Power Off") systemctl poweroff ;;
"  Reboot") systemctl reboot ;;
"  Logout") hyprctl dispatch exit ;;
"  Lock") swaylock ;; # 替换为你的锁屏工具
esac
