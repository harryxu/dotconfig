# Rime 配置 (Arch Linux & macOS)

基于 [Rime](https://rime.im/) 与 [雾凇拼音 (rime-ice)](https://github.com/iDvel/rime-ice) 的个人输入法配置，用于在 Arch Linux (Fcitx5) 与 macOS (Squirrel) 之间共用同一套配置文件。


## 使用方法

### macOS (鼠须管)

1. 确保已安装 Homebrew 和 git。
2. 运行安装脚本：

   ```bash
   cd ~/.config/rime
   ./install.sh
   ```

> **提示**：初次安装鼠须管后，需在 macOS「系统设置 -> 键盘 -> 输入法」中手动添加「鼠须管」。

### Arch Linux (Fcitx5)

1. 安装输入法框架与雾凇拼音包：
   ```bash
   paru -S fcitx5-rime rime-ice-git
   # 或
   yay -S fcitx5-rime rime-ice-git
   ```
2. 运行安装脚本挂载配置：
   ```bash
   cd ~/.config/rime
   ./install.sh
   ```
   脚本会将配置文件软链接至 `~/.local/share/fcitx5/rime/` 并触发重新部署。

## 配置兼容说明

共用 `default.custom.yaml`


- **Arch Linux**：AUR 的 `rime-ice-git` 将默认预设安装为系统目录下的 `rime_ice_suggestion.yaml`。
- **macOS**：雾凇拼音官方仓库中的默认文件名是 `default.yaml`。`install.sh` 会在 macOS 端建立 `rime_ice_suggestion.yaml -> default.yaml` 的软链接，从而让同一份配置在两端均能正常生效。

## 重新部署命令

修改配置后可通过以下命令应用变更：

- **macOS**：`"/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --reload`
- **Linux**：`fcitx5-remote -r`

## 参考链接

- [Rime 定制指南](https://raw.githubusercontent.com/wiki/rime/home/CustomizationGuide.md)
- [鼠鬚管配置指南](https://github.com/rime/squirrel/wiki/squirrel.yaml-%E9%85%8D%E7%BD%AE%E6%8C%87%E5%8D%97)
- [雾凇拼音文档](https://github.com/iDvel/rime-ice/blob/main/others/docs/Installation.md)
