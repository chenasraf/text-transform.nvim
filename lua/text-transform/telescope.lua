local D = require("text-transform.util.debug")
local state = require("text-transform.state")
local replacers = require("text-transform.replacers")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local telescope_conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local dropdown = require("telescope.themes").get_dropdown({})
local Sorter = require("telescope.sorters").Sorter
local generic_sorter = telescope_conf.generic_sorter()

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

local default_frequency = {
  camel_case = 1,
  snake_case = 1,
  pascal_case = 1,
  kebab_case = 1,
  dot_case = 1,
  title_case = 1,
  const_case = 1,
}

local frequency_file = vim.fn.stdpath("config") .. "/text-transform-frequency.json"
local frequency

local function load_frequency()
  if frequency then
    return frequency
  end
  if vim.fn.filereadable(frequency_file) == 0 then
    frequency = default_frequency
    vim.fn.writefile({ vim.fn.json_encode(frequency) }, frequency_file)
  else
    frequency = vim.fn.json_decode(vim.fn.readfile(frequency_file))
  end
  D.log("telescope", "frequency loaded: %s", vim.inspect(frequency))
  return frequency
end

local function inc_frequency(name)
  frequency[name] = (frequency[name] or 0) + 1
  D.log("telescope", "new frequency: %s %d", name, frequency[name])
  vim.fn.writefile({ vim.fn.json_encode(frequency) }, frequency_file)
end

local function entry_maker(entry)
  return {
    value = entry.value,
    display = entry.label,
    ordinal = entry.label,
    frequency = frequency[entry.value] or 1,
  }
end

local frequency_sorter = Sorter:new({
  ---@diagnostic disable-next-line: unused-local
  scoring_function = function(self, prompt, line)
    local entry
    for _, item in ipairs(items) do
      if item.label == line then
        entry = entry_maker(item)
        break
      end
    end
    D.log("telescope", "prompt %s line %s", prompt, line)
    -- Basic filtering based on prompt matching, non-matching items score below 0 to exclude them
    local basic_score = (generic_sorter:scoring_function(prompt, line) or 0)
    D.log("telescope", "%s basic_score: %s", entry.value, basic_score)
    if basic_score < 0 then
      return basic_score
    end

    -- D.log("telescope", "entry: %s", vim.inspect(entry))
    -- D.log("telescope", "prompt: %s", prompt)
    -- Calculate score based on frequency, higher frequency should have lower score
    local freq_score = (entry.frequency or 1) * 10

    D.log("telescope", "freq_score: %s", freq_score)

    local final_score = 999999999 - freq_score + basic_score
    D.log("telescope", "%s final_score: %s", line, final_score)

    -- Combine scores, with frequency having the primary influence if present
    return final_score
  end,
})
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
  load_frequency()

  local filtered = {}
  print(vim.inspect(_G.TextTransform.config))
  local config = _G.TextTransform.config

  for _, item in ipairs(items) do
    if not config.replacers[item.value] or not config.replacers[item.value].enabled then
      goto continue
    end
    table.insert(filtered, item)
    ::continue::
  end

  local picker = pickers.new(dropdown, {
    prompt_title = "Change Case",
    finder = finders.new_table({
      results = items,
      entry_maker = entry_maker,
    }),
    sorter = frequency_sorter,
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        inc_frequency(selection.value)
        actions.close(prompt_bufnr)
        vim.schedule(function()
          replacers.replace_selection(selection.value)
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
