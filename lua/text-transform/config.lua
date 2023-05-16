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

  -- use input from current word in editor
  vim.cmd(
    "amenu TransformsSelection.&camelCase    :lua TextTransform.replace_selection(TextTransform.camel_case)<CR>"
  )
  vim.cmd(
    "amenu TransformsSelection.&snake_case   :lua TextTransform.replace_selection(TextTransform.snake_case)<CR>"
  )
  vim.cmd(
    "amenu TransformsSelection.&PascalCase   :lua TextTransform.replace_selection(TextTransform.pascal_case)<CR>"
  )
  vim.cmd(
    "amenu TransformsSelection.&kebab-case   :lua TextTransform.replace_selection(TextTransform.kebab_case)<CR>"
  )
  vim.cmd(
    "amenu TransformsSelection.&dot\\.case   :lua TextTransform.replace_selection(TextTransform.dot_case)<CR>"
  )
  vim.cmd(
    "amenu TransformsSelection.&Title\\ Case :lua TextTransform.replace_selection(TextTransform.title_case)<CR>"
  )
  vim.cmd(
    "amenu TransformsSelection.C&ONST_CASE\\ Case :lua TextTransform.replace_selection(TextTransform.const_case)<CR>"
  )

  -- use input from current word in editor
  vim.cmd(
    "amenu TransformsWord.&camelCase    :lua TextTransform.replace_word(TextTransform.camel_case)<CR>"
  )
  vim.cmd(
    "amenu TransformsWord.&snake_case   :lua TextTransform.replace_word(TextTransform.snake_case)<CR>"
  )
  vim.cmd(
    "amenu TransformsWord.&PascalCase   :lua TextTransform.replace_word(TextTransform.pascal_case)<CR>"
  )
  vim.cmd(
    "amenu TransformsWord.&kebab-case   :lua TextTransform.replace_word(TextTransform.kebab_case)<CR>"
  )
  vim.cmd(
    "amenu TransformsWord.&dot\\.case   :lua TextTransform.replace_word(TextTransform.dot_case)<CR>"
  )
  vim.cmd(
    "amenu TransformsWord.&Title\\ Case :lua TextTransform.replace_word(TextTransform.title_case)<CR>"
  )
  vim.cmd(
    "amenu TransformsWord.C&ONST_CASE\\ Case :lua TextTransform.replace_word(TextTransform.const_case)<CR>"
  )

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
