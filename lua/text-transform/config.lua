local popup = require("text-transform.popup")
local commands = require("text-transform.commands")
local D = require("text-transform.util.debug")
local utils = require("text-transform.util")
local TextTransform = {}

--- Your plugin configuration with its default values.
---
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
TextTransform.options = {
  --- Prints information about internals of the plugin. Very verbose, only useful for debugging.
  debug = false,
  --- Keymap configurations
  keymap = {
    --- Keymap to open the telescope popup. Set to `false` or `nil` to disable keymapping
    --- You can always customize your own keymapping manually.
    telescope_popup = {
      --- Opens the popup in normal mode
      ["n"] = "<Leader>~",
      --- Opens the popup in visual/visual block modes
      ["v"] = "<Leader>~",
    },
  },
  ---
  --- Configurations for the text-transform replacers
  --- Keys indicate the replacer name, and the value is a table with the following options:
  ---
  --- - `enabled` (boolean): Enable or disable the replacer - disabled replacers do not show up in the popup.
  replacers = {
    camel_case = { enabled = true },
    const_case = { enabled = true },
    dot_case = { enabled = true },
    kebab_case = { enabled = true },
    pascal_case = { enabled = true },
    snake_case = { enabled = true },
    title_case = { enabled = true },
  },

  --- Sort the replacers in the popup.
  --- Possible values: 'frequency', 'name'
  sort_by = "frequency",

  --- The popup type to show.
  --- Possible values: 'telescope', 'select'
  popup_type = "telescope",
}

local function init()
  local o = TextTransform.options
  D.log("config", "Initializing TextTransform with %s", utils.dump(o))
  commands.init_commands()

  if o.keymap.telescope_popup then
    local keys = o.keymap.telescope_popup
    if keys.n then
      vim.keymap.set("n", keys.n, popup.show_popup, { silent = true, desc = "Change Case" })
    end
    if keys.v then
      vim.keymap.set("v", keys.v, popup.show_popup, { silent = true, desc = "Change Case" })
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
