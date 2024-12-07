-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

function GetFont(family, weight)
  weight = weight or 500
  return wezterm.font_with_fallback({
    { family = family, weight = weight },
    "Monaco",
    "Consolas",
    "VictorMono Nerd Font",
    "Courier New",
    "DejaVu Sans Mono",
  })
end

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- Color scheme
config.color_scheme = "Relaxed"

config.font = GetFont("IosevkaTerm Nerd Font", 500)
config.font_size = 23.0

config.command_palette_font_size = 19

config.window_padding = {
  top = 0,
  bottom = 0,
}

--config.window_decorations = 'RESIZE'

config.enable_kitty_keyboard = true
config.enable_csi_u_key_encoding = false

-- Tab Bar
config.use_fancy_tab_bar = true
config.tab_max_width = 100
config.window_frame = {
  font = GetFont("Iosevka Nerd Font", 500),
  font_size = 18,
}

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
function TabTitle(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title .. "   #" .. (tab_info.tab_id + 1)
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title .. "   #" .. (tab_info.tab_id + 1)
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#C5C5C5"
  local foreground = "#808080"

  if tab.is_active then
    background = "#F0EDED"
    foreground = "#000000"
  end

  local title = TabTitle(tab)

  -- ensure that the titles fit in the available space,
  -- and that we have room for the edges.
  --title = wezterm.truncate_right(title, max_width - 2)

  return {
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = "  " },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = "  " },
  }
end)

-- Key Bindings
config.keys = {
  {
    key = "t",
    mods = "CMD",
    action = act.SpawnCommandInNewTab({ cwd = wezterm.home_dir }),
  },
}

return config
