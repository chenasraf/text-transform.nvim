local replacers = require("text-transform.replacers")
local telescope = require("text-transform.telescope")
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
      replacers.replace_selection(transformer_name)
    end, {})
  end

  vim.api.nvim_create_user_command("TtTelescope", telescope.popup, {})
  vim.api.nvim_create_user_command("TextTransform", telescope.popup, {})
end

return TextTransform
