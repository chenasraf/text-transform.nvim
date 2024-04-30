local state = require("text-transform.state")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local dropdown = require("telescope.themes").get_dropdown({})

local TextTransform = {}

local items = {
  { label = "camelCase", value = "camel_case" },
  { label = "snake_case", value = "snake_case" },
  { label = "PascalCase", value = "pascal_case" },
  { label = "kebab-case", value = "kebab_case" },
  { label = "dot.case", value = "dot_case" },
  { label = "Title Case", value = "title_case" },
  { label = "CONST_CASE", value = "const_case" },
}

---@diagnostic disable-next-line: unused-local
-- for _i, k in pairs(default_ordered_keys) do
--   local v = map[k]
--   vim.cmd("amenu TransformsWord." .. k .. " :lua TextTransform.replace_word('" .. v .. "')<CR>")
--   vim.cmd(
--     "amenu TransformsSelection." .. k .. " :lua TextTransform.replace_columns('" .. v .. "')<CR>"
--   )
-- end

--- Pops up a telescope menu, containing the available case transformers.
--- When a transformer is selected, the cursor position/range/columns will be used to replace the
--- words around the cursor or inside the selection.
---
--- The cursor positions/ranges are saved before opening the menu and restored once a selection is
--- made.
function TextTransform.popup()
  state.save_positions()

  local picker = pickers.new(dropdown, {
    prompt_title = "Change Case",
    finder = finders.new_table({
      results = items,
      entry_maker = function(entry)
        return {
          value = entry.value,
          display = entry.label,
          ordinal = entry.label,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.schedule(function()
          TextTransform.replace_selection(selection.value)
          state.restore_positions()
        end)
      end)
      return true
    end,
  })
  vim.schedule(function()
    picker:find()
  end)
end

return TextTransform
