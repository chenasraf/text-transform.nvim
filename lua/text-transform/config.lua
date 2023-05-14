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

    return TextTransform.options
end

return TextTransform
