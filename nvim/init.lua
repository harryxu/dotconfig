-- Mini mode: if mini.mode exists in the config directory, skip plugins entirely.
local mini_mode_flag = vim.fn.stdpath("config") .. "/mini.mode"
if vim.fn.filereadable(mini_mode_flag) == 1 then
  require("config.options")
  vim.notify(
    "Currently in mini mode. Run `manager.sh unmini` to exit mini mode.",
    vim.log.levels.WARN,
    { title = "Neovim" }
  )
else
  require("config.lazy")
end

local local_config = vim.fn.stdpath("config") .. "/local.lua"
if vim.fn.filereadable(local_config) == 1 then
  dofile(local_config)
end
