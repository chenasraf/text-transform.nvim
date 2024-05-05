local commands = require("text-transform.commands")
local D = require("text-transform.utils.debug")
local utils = require("text-transform.utils")
local TextTransform = {}

local function ensure_config()
  -- when the config is not set to the global object, we set it
  if _G.TextTransform.config == nil then
    _G.TextTransform.config = TextTransform.config
  end
end

local function init()
  ensure_config()
  local o = TextTransform.config
  D.log("config", "Initializing TextTransform with %s", vim.inspect(o))
  commands.init_commands()
  commands.init_keymaps()
end

--- Your plugin configuration with its default values.
---
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
TextTransform.config = {
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

--- Define your text-transform setup.
---
---@param options table Module config table. See |TextTransform.options|.
---
---@usage `require("text-transform").setup()` (add `{}` with your |TextTransform.options| table)
function TextTransform.setup(options)
  options = options or {}

  TextTransform.config = utils.merge(TextTransform.config, options)

  if vim.api.nvim_get_vvar("vim_did_enter") == 0 then
    vim.defer_fn(function()
      init()
    end, 0)
  else
    init()
  end

  return TextTransform.config
end

return TextTransform
