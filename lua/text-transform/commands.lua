local state = require("text-transform.state")
local replacers = require("text-transform.replacers")
local popup = require("text-transform.popup")
local TextTransform = {}

--- Initializes user commands
--- @private
function TextTransform.init_commands()
  local map = {
    TtCamel = "camel_case",
    TtConst = "const_case",
    TtDot = "dot_case",
    TtKebab = "kebab_case",
    TtPascal = "pascal_case",
    TtSnake = "snake_case",
    TtTitle = "title_case",
  }

  for cmd, transformer_name in pairs(map) do
    vim.api.nvim_create_user_command(cmd, function()
      state.save_positions()
      replacers.replace_selection(transformer_name)
    end, {})
  end

  -- specific popups
  vim.api.nvim_create_user_command("TtTelescope", popup.telescope_popup, {})
  vim.api.nvim_create_user_command("TtSelect", popup.select_popup, {})

  -- auto popup by config
  vim.api.nvim_create_user_command("TextTransform", popup.show_popup, {})
end

return TextTransform
