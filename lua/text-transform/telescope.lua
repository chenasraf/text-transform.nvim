local common = require("text-transform.popup_common")
local D = require("text-transform.util.debug")
local state = require("text-transform.state")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local telescope_conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local dropdown = require("telescope.themes").get_dropdown({})
local Sorter = require("telescope.sorters").Sorter

local telescope = {}

local frequency_sorter = Sorter:new({
  ---@diagnostic disable-next-line: unused-local
  scoring_function = function(self, prompt, line)
    local generic_sorter = telescope_conf.generic_sorter()
    generic_sorter:init()
    local entry
    for _, item in ipairs(common.items) do
      if item.label == line then
        entry = common.entry_maker(item)
        break
      end
    end
    D.log("frequency_sorter", "entry %s", vim.inspect(entry))
    D.log("frequency_sorter", "prompt %s line %s", prompt, line)
    -- Basic filtering based on prompt matching, non-matching items score below 0 to exclude them
    local basic_score = (generic_sorter:scoring_function(prompt, line) or 1)
    D.log("frequency_sorter", "%s basic_score: %s", entry.value, basic_score)
    if basic_score < 0 then
      return basic_score
    end

    -- D.log("frequency_sorter", "entry: %s", vim.inspect(entry))
    -- D.log("frequency_sorter", "prompt: %s", prompt)
    -- Calculate score based on frequency, higher frequency should have lower score
    local freq_score = (entry.frequency or 1) * 10

    D.log("frequency_sorter", "freq_score: %s", freq_score)

    local final_score = 999999999 - freq_score + basic_score
    D.log("frequency_sorter", "%s final_score: %s", line, final_score)

    -- Combine scores, with frequency having the primary influence if present
    return final_score
  end,
})

local generic_sorter = telescope_conf.generic_sorter()
local sorter_map = {
  frequency = frequency_sorter,
  name = generic_sorter,
}

--- Pops up a telescope menu, containing the available case transformers.
--- When a transformer is selected, the cursor position/range/columns will be used to replace the
--- words around the cursor or inside the selection.
---
--- The cursor positions/ranges are saved before opening the menu and restored once a selection is
--- made.
function telescope.telescope_popup()
  state.save_positions()

  local filtered = {}
  local config = _G.TextTransform.config
  local sorter = sorter_map[config.sort_by] or generic_sorter

  if config.sort_by == "frequency" then
    common.load_frequency()
  end

  for _, item in ipairs(common.items) do
    if config.replacers[item.value] and not config.replacers[item.value].enabled then
      goto continue
    end
    table.insert(filtered, item)
    ::continue::
  end

  local picker = pickers.new(dropdown, {
    prompt_title = "Change Case",
    finder = finders.new_table({
      results = common.items,
      entry_maker = common.entry_maker,
    }),
    sorter = sorter,
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        common.inc_frequency(selection.value)
        actions.close(prompt_bufnr)
        common.select(selection)
      end)
      return true
    end,
  })
  vim.schedule(function()
    picker:find()
  end)
end

return telescope
