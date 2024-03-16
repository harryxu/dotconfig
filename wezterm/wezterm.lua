-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Relaxed'

config.font = wezterm.font('Iosevka Nerd Font', {weight=500})
config.font_size = 23.0

config.window_frame = {
  font = wezterm.font('Iosevka Nerd Font', {weight=500}),
  font_size = 18,
}


-- and finally, return the configuration to wezterm
return config
