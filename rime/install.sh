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
    echo "🍎 检测到系统: macOS (Squirrel)"

    # 1. 检测 Squirrel 是否安装，没有安装的话使用 Homebrew 安装
    if [ ! -d "/Library/Input Methods/Squirrel.app" ] && [ ! -d "$HOME/Library/Input Methods/Squirrel.app" ]; then
      echo "🔍 未检测到鼠须管 (Squirrel)，准备通过 Homebrew 安装..."
      if command -v brew &>/dev/null; then
        echo "🍺 正在执行: brew install --cask squirrel-app"
        brew install --cask squirrel-app
      else
        echo "❌ 未检测到 Homebrew，请先安装 Homebrew (https://brew.sh) 或手动安装鼠须管 (https://rime.im/)"
        exit 1
      fi
    else
      echo "✅ 检测到鼠须管 (Squirrel) 已安装"
    fi

    # 设置部署命令
    if [ -f "/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" ]; then
      DEPLOY_CMD='"/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --reload'
    elif [ -f "$HOME/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" ]; then
      DEPLOY_CMD="\"$HOME/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel\" --reload"
    fi

    # 2. 克隆/更新 雾凇拼音 仓库
    RIME_ICE_REPO="https://github.com/iDvel/rime-ice.git"
    if [ ! -d "$TARGET_DIR/.git" ]; then
      if [ -d "$TARGET_DIR" ] && [ -n "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]; then
        BACKUP_DIR="${TARGET_DIR}_backup_$(date +%Y%m%d%H%M%S)"
        echo "⚠️  $TARGET_DIR 已存在且非空，正在备份到 $BACKUP_DIR ..."
        mv "$TARGET_DIR" "$BACKUP_DIR"
        echo "📥 正在克隆雾凇拼音仓库到 $TARGET_DIR ..."
        git clone "$RIME_ICE_REPO" "$TARGET_DIR" --depth 1
        echo "📦 正在恢复历史用户词库与关键数据..."
        for item in "$BACKUP_DIR"/*.userdb "$BACKUP_DIR"/installation.yaml "$BACKUP_DIR"/user.yaml; do
          [ -e "$item" ] && cp -r "$item" "$TARGET_DIR/" 2>/dev/null || true
        done
        echo "✅ 备份保存在: $BACKUP_DIR"
      else
        echo "📥 正在克隆雾凇拼音仓库到 $TARGET_DIR ..."
        git clone "$RIME_ICE_REPO" "$TARGET_DIR" --depth 1
      fi
    else
      echo "📦 检测到雾凇拼音仓库已存在，正在尝试拉取更新..."
      git -C "$TARGET_DIR" pull --ff-only || echo "⚠️  自动拉取失败，保持现有版本。"
    fi

    # 3. 创建所需的软链接 (对齐 Arch Linux 命名规范: rime_ice_suggestion.yaml -> default.yaml)
    if [ -f "$TARGET_DIR/default.yaml" ]; then
      echo "🔗 正在创建 rime_ice_suggestion.yaml 软链接..."
      ln -sf default.yaml "$TARGET_DIR/rime_ice_suggestion.yaml"
      echo "  ✅ 已链接: rime_ice_suggestion.yaml -> default.yaml"
    fi
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

    mkdir -p "$TARGET_DIR"
    ;;

  *)
    echo "❌ 暂不支持的操作系统: $OS"
    exit 1
    ;;
esac

# 4. 链接当前配置目录中的配置文件到目标目录中
echo "📂 目标目录: $TARGET_DIR"
echo "🔗 正在链接当前目录自定义配置到目标目录..."
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

# 5. 触发重新部署
echo "🔄 正在触发 Rime 重新部署..."
if [ -n "$DEPLOY_CMD" ]; then
  eval "$DEPLOY_CMD" || true
  echo "🎉 部署完成！配置已生效。"
else
  echo "💡 请手动在输入法菜单中点击「重新部署」（Deploy）。"
fi

if [ "$OS" = "Darwin" ]; then
  echo "💡 提示: 若首次安装鼠须管，请前往「系统设置 -> 键盘 -> 输入法」添加「鼠须管」，或注销后重新登录。"
fi
