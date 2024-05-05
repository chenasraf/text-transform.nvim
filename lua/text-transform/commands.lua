local D = require("text-transform.utils.debug")
local util = require("text-transform.utils")
local state = require("text-transform.state")
local replacers = require("text-transform.replacers")
local popup = require("text-transform.popup")
local common = require("text-transform.popup.common")

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
      vim.schedule(function()
        state.restore_positions()
      end)
    end, opts("Change to " .. item))
  end

  -- specific popups
  vim.api.nvim_create_user_command("TtTelescope", function()
    local telescope = require("text-transform.popup.telescope")
    telescope.telescope_popup()
  end, opts("Change Case with Telescope"))
  vim.api.nvim_create_user_command("TtSelect", function()
    local select = require("text-transform.popup.select")
    select.select_popup()
  end, opts("Change Case with Select"))

  -- auto popup by config
  vim.api.nvim_create_user_command("TextTransform", popup.show_popup, opts("Change Case"))
end

--- Initializes user keymaps
--- @private
function TextTransform.init_keymaps()
  local keymaps = _G.TextTransform.config.keymap
  D.log("init_keymaps", "Initializing keymaps, config %s", vim.inspect(_G.TextTransform))
  if keymaps.telescope_popup then
    local keys = keymaps.telescope_popup
    if keys.n then
      vim.keymap.set("n", keys.n, popup.show_popup, { silent = true, desc = "Change Case" })
    end
    if keys.v then
      vim.keymap.set("v", keys.v, popup.show_popup, { silent = true, desc = "Change Case" })
    end
  end
end

return TextTransform
