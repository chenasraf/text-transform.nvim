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
        "<Leader>~",
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
    vim.cmd("amenu Transforms.&camelCase :lua ReplaceCurrentWord(CamelCase)<CR>")
    vim.cmd("amenu Transforms.&snake_case :lua ReplaceCurrentWord(SnakeCase)<CR>")
    vim.cmd("amenu Transforms.&PascalCase :lua ReplaceCurrentWord(PascalCase)<CR>")
    vim.cmd("amenu Transforms.&kebab-case :lua ReplaceCurrentWord(KebabCase)<CR>")
    vim.cmd("amenu Transforms.&dot\\.case :lua ReplaceCurrentWord(DotCase)<CR>")
    vim.cmd("amenu Transforms.&Title\\ Case :lua ReplaceCurrentWord(TitleCase)<CR>")

    for kmap in TextTransform.options.keymap do
        vim.keymap.set({ "n", "v" }, kmap, "<cmd>popup Transforms<CR>", { silent = true })
    end

    return TextTransform.options
end

return TextTransform
