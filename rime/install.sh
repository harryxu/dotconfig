#!/usr/bin/env bash
set -e

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. 检测操作系统及目标配置目录
OS="$(uname -s)"
TARGET_DIR=""
DEPLOY_CMD=""

case "$OS" in
  Darwin)
    TARGET_DIR="$HOME/Library/Rime"
    if [ -f "/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" ]; then
      DEPLOY_CMD='"/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --reload'
    fi
    echo "🍎 检测到系统: macOS (Squirrel)"
    ;;
  Linux)
    # 按照常用优先级检测安装的输入法框架
    if [ -d "$HOME/.local/share/fcitx5/rime" ] || command -v fcitx5 &>/dev/null; then
      TARGET_DIR="$HOME/.local/share/fcitx5/rime"
      DEPLOY_CMD="fcitx5-remote -r || true"
      echo "🐧 检测到系统: Linux (fcitx5-rime)"
    elif [ -d "$HOME/.config/ibus/rime" ] || command -v ibus &>/dev/null; then
      TARGET_DIR="$HOME/.config/ibus/rime"
      DEPLOY_CMD="touch $HOME/.config/ibus/rime/ && ibus restart"
      echo "🐧 检测到系统: Linux (ibus-rime)"
    elif [ -d "$HOME/.config/fcitx/rime" ] || command -v fcitx &>/dev/null; then
      TARGET_DIR="$HOME/.config/fcitx/rime"
      DEPLOY_CMD="fcitx-remote -r || true"
      echo "🐧 检测到系统: Linux (fcitx-rime)"
    else
      TARGET_DIR="$HOME/.local/share/fcitx5/rime"
      echo "⚠️ 未能明确检测到 Linux 输入法框架，默认使用: $TARGET_DIR"
    fi
    ;;
  *)
    echo "❌ 暂不支持的操作系统: $OS"
    exit 1
    ;;
esac

# 2. 确保目标目录存在
mkdir -p "$TARGET_DIR"
echo "📂 目标目录: $TARGET_DIR"
echo "🔗 正在创建符号链接..."

# 3. 遍历当前目录下的所有 yaml 文件及 txt 词库文件
for file in "$SCRIPT_DIR"/*.yaml "$SCRIPT_DIR"/*.txt; do
  [ -e "$file" ] || continue
  filename="$(basename "$file")"
  target_file="$TARGET_DIR/$filename"

  # 如果目标已存在且不是指向当前文件的软链接，做备份
  if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
    echo "  📦 备份现有文件: $filename -> $filename.bak"
    mv "$target_file" "$target_file.bak"
  fi

  # 建立软链接
  ln -sf "$file" "$target_file"
  echo "  ✅ 已链接: $filename -> $target_file"
done

# 4. 触发重新部署
echo "🔄 正在触发 Rime 重新部署..."
if [ -n "$DEPLOY_CMD" ]; then
  eval "$DEPLOY_CMD"
  echo "🎉 部署完成！配置已生效。"
else
  echo "💡 请手动在输入法菜单中点击「重新部署」。"
fi
