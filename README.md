# harry's dotconfig

## Installation

```sh
curl -s https://raw.githubusercontent.com/harryxu/dotconfig/refs/heads/main/install.sh -o /tmp/dotconfig_install.sh && bash /tmp/dotconfig_install.sh
```

The installer uses Python 3 to apply `zed/settings.shared.jsonc` to the local
`~/.config/zed/settings.json`. To apply shared settings again after pulling an
update, run `bash ~/.config/install.sh --zed-settings`.
