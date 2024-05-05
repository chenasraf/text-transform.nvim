-- local D = require("text-transform.util.debug")
local util = require("text-transform.util")
local state = require("text-transform.state")
local replacers = require("text-transform.replacers")
local popup = require("text-transform.popup")
local common = require("text-transform.popup_common")
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

  local cmdopts = { range = true, force = true }
  local opts = function(desc)
    return util.merge(cmdopts, { desc = desc })
  end

  for cmd, transformer_name in pairs(map) do
    local item
    for _, t in ipairs(common.items) do
      if t.value == transformer_name then
        item = t.label
        break
      end
    end
    vim.api.nvim_create_user_command(cmd, function()
      state.save_positions()
      replacers.replace_selection(transformer_name)
    end, opts("Change to " .. item))
  end

  -- specific popups
  vim.api.nvim_create_user_command("TtTelescope", function()
    local telescope = require("text-transform.telescope")
    telescope.telescope_popup()
  end, opts("Change Case with Telescope"))
  vim.api.nvim_create_user_command("TtSelect", function()
    local select = require("text-transform.select")
    select.select_popup()
  end, opts("Change Case with Select"))

  -- auto popup by config
  vim.api.nvim_create_user_command("TextTransform", popup.show_popup, opts("Change Case"))
end

return TextTransform
