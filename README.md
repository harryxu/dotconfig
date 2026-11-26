# harry's dotconfig

## Installation

```sh
curl -s https://raw.githubusercontent.com/harryxu/dotconfig/refs/heads/main/install.sh -o /tmp/dotconfig_install.sh && bash /tmp/dotconfig_install.sh
```

The installer uses Python 3 to apply `zed/settings.shared.jsonc` to the local
`~/.config/zed/settings.json`. To apply shared settings again after pulling an
update, run `bash ~/.config/install.sh --zed-settings`.

To export changes from Zed, run `~/.config/zed/export_settings.py`. It regenerates
`settings.shared.jsonc` from the local settings, excluding the top-level keys in
`LOCAL_ONLY_KEYS` in the script. Review the resulting Git diff before committing.

The installer also sets up prek to export and commit shared Zed settings after
each commit in this repository. If a shared `core.hooksPath` is configured, the
installer uses a repository-local hook registration, which requires Git 2.54 or
newer.
