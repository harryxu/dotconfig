-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

function get_font(family, weight)
  weight = weight or 500
  return wezterm.font_with_fallback({
    { family = family, weight = weight },
    'Monaco',
    'Consolas',
    'Courier New',
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
config.color_scheme = 'Relaxed'

config.font = get_font('Iosevka Nerd Font', 500)
config.font_size = 23.0

config.window_frame = {
  font = get_font('Iosevka Nerd Font', 500),
  font_size = 18,
}

-- Key Bindings
config.keys = {
  {
    key = 't',
    mods = 'CMD',
    action = act.SpawnCommandInNewTab { cwd = wezterm.home_dir } 
  }
}


return config
