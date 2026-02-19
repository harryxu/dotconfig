-- Mini mode: if mini.mode exists in the config directory, skip plugins entirely.
local mini_mode_flag = vim.fn.stdpath("config") .. "/mini.mode"
if vim.fn.filereadable(mini_mode_flag) == 1 then
  require("config.options")
else
  require("config.lazy")
end
