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

--- Define your text-transform setup.
---
---@param options table Module config table. See |TextTransform.options|.
---
---@usage `require("text-transform").setup()` (add `{}` with your |TextTransform.options| table)
function TextTransform.setup(options)
  options = options or {}

  TextTransform.options = vim.tbl_deep_extend("keep", options, TextTransform.options)

  if vim.api.nvim_get_vvar("vim_did_enter") == 0 then
    vim.defer_fn(function()
      TextTransform._setup()
    end, 0)
  else
    TextTransform._setup()
  end

  return TextTransform.options
end

local CAMEL_CASE = "&camelCase"
local SNAKE_CASE = "&snake_case"
local PASCAL_CASE = "&PascalCase"
local KEBAB_CASE = "&kebab-case"
local DOT_CASE = "&dot\\.case"
local TITLE_CASE = "&Title\\ Case"
local CONST_CASE = "C&ONST_CASE"

-- TODO save frequency of use and order by frequency
local default_ordered_keys =
  { CAMEL_CASE, SNAKE_CASE, PASCAL_CASE, CONST_CASE, KEBAB_CASE, DOT_CASE, TITLE_CASE }

function TextTransform._setup()
  local map = {
    [CAMEL_CASE] = "camel_case",
    [SNAKE_CASE] = "snake_case",
    [PASCAL_CASE] = "pascal_case",
    [KEBAB_CASE] = "kebab_case",
    [DOT_CASE] = "dot_case",
    [TITLE_CASE] = "title_case",
    [CONST_CASE] = "const_case",
  }

  ---@diagnostic disable-next-line: unused-local
  for _i, k in pairs(default_ordered_keys) do
    local v = map[k]
    vim.cmd("amenu TransformsWord." .. k .. " :lua TextTransform.replace_word('" .. v .. "')<CR>")
    vim.cmd(
      "amenu TransformsSelection." .. k .. " :lua TextTransform.replace_columns('" .. v .. "')<CR>"
    )
  end

  vim.keymap.set(
    "n",
    TextTransform.options.keymap.n,
    "<cmd>popup TransformsWord<CR>",
    { silent = true }
  )
  vim.keymap.set(
    "v",
    TextTransform.options.keymap.v,
    "<cmd>popup TransformsSelection<CR>",
    { silent = true }
  )
end

return TextTransform
