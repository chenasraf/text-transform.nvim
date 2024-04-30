local telescope_popup = require("text-transform.telescope")
local D = require("text-transform.util.debug")
local utils = require("text-transform.util")
local TextTransform = {}

--- Your plugin configuration with its default values.
---
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
TextTransform.options = {
  -- Prints useful logs about what event are triggered, and reasons actions are executed.
  debug = false,
  -- Keymap to trigger the transform.
  keymap = {
    -- Normal mode keymap.
    ["n"] = "<Leader>~",
    -- Visual mode keymap.
    ["v"] = "<Leader>~",
  },
}

local function init()
  local o = TextTransform.options
  D.log("config", "Initializing TextTransform with %s", utils.dump(o))

  vim.keymap.set("n", o.keymap.n, telescope_popup, { silent = true })
  vim.keymap.set("v", o.keymap.v, telescope_popup, { silent = true })
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
