local telescope = require("text-transform.telescope")
local commands = require("text-transform.commands")
local D = require("text-transform.util.debug")
local utils = require("text-transform.util")
local TextTransform = {}

--- Your plugin configuration with its default values.
---
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
TextTransform.options = {
  -- Prints information about internals of the plugin. Very verbose, only useful for debugging.
  debug = false,
  -- Keymap configurations
  keymap = {
    -- Keymap to open the telescope popup. Set to `false` or `nil` to disable keymapping
    -- You can always customize your own keymapping manually.
    telescope_popup = {
      -- Opens the popup in normal mode
      ["n"] = "<Leader>~",
      -- Opens the popup in visual/visual block modes
      ["v"] = "<Leader>~",
    },
  },
}

local function init()
  local o = TextTransform.options
  D.log("config", "Initializing TextTransform with %s", utils.dump(o))
  commands.init_commands()

  if o.keymap.telescope_popup then
    local keys = o.keymap.telescope_popup
    if keys.n then
      vim.keymap.set("n", keys.n, telescope.popup, { silent = true })
    end
    if keys.v then
      vim.keymap.set("v", keys.v, telescope.popup, { silent = true })
    end
  end
end

--- Define your text-transform setup.
---
---@param options table Module config table. See |TextTransform.options|.
---
---@usage `require("text-transform").setup()` (add `{}` with your |TextTransform.options| table)
function TextTransform.setup(options)
  options = options or {}

  TextTransform.options = utils.merge(TextTransform.options, options)

  if vim.api.nvim_get_vvar("vim_did_enter") == 0 then
    vim.defer_fn(function()
      init()
    end, 0)
  else
    init()
  end

  return TextTransform.options
end

return TextTransform
