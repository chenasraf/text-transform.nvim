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

  local map = {
    ["&camelCase"] = "TextTransform.camel_case",
    ["&snake_case"] = "TextTransform.snake_case",
    ["&PascalCase"] = "TextTransform.pascal_case",
    ["&kebab-case"] = "TextTransform.kebab_case",
    ["&dot\\.case"] = "TextTransform.dot_case",
    ["&Title\\ Case"] = "TextTransform.title_case",
    ["C&ONST_CASE"] = "TextTransform.const_case",
  }

  for k, v in pairs(map) do
    vim.cmd("amenu TransformsWord." .. k .. " :lua TextTransform.replace_word(" .. v .. ")<CR>")
    vim.cmd(
      "amenu TransformsSelection." .. k .. " :lua TextTransform.replace_selection(" .. v .. ")<CR>"
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

  return TextTransform.options
end

return TextTransform
