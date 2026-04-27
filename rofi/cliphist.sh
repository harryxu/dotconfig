#!/bin/bash

# 获取cliphist历史记录
cliphist_output=$(cliphist list)

# 将历史记录和自定义操作组合
options=$(printf "%s\n> Wipe\n❯ Compact" "$cliphist_output")

# 通过rofi显示选项并获取用户选择
selected=$(echo "$options" | rofi -dmenu -i -p "cliphist" -theme ~/.config/rofi/themes/rounded-nord-dark.rasi -me-select-entry ''  -me-accept-entry MousePrimary -hover-select)

# 如果用户取消选择（按Esc或关闭窗口）
if [ -z "$selected" ]; then
    exit 0
fi

# 根据选择执行相应操作
if [ "$selected" = "Wipe" ]; then
    cliphist wipe
elif [ "$selected" = "Compact" ]; then
    cliphist compact
else
    # 处理历史项选择：decode后复制到剪贴板
    echo "$selected" | cliphist decode | wl-copy
fi
