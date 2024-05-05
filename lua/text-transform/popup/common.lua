local D = require("text-transform.utils.debug")
local state = require("text-transform.state")
local replacers = require("text-transform.replacers")

local popup_common = {}

popup_common.items = {
  { label = "camelCase", value = "camel_case" },
  { label = "snake_case", value = "snake_case" },
  { label = "PascalCase", value = "pascal_case" },
  { label = "kebab-case", value = "kebab_case" },
  { label = "dot.case", value = "dot_case" },
  { label = "Title Case", value = "title_case" },
  { label = "CONST_CASE", value = "const_case" },
}

popup_common.default_frequency = {
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

function popup_common.load_frequency()
  if frequency then
    return frequency
  end
  if vim.fn.filereadable(frequency_file) == 0 then
    frequency = popup_common.default_frequency
    vim.fn.writefile({ vim.fn.json_encode(frequency) }, frequency_file)
  else
    frequency = vim.fn.json_decode(vim.fn.readfile(frequency_file))
  end
  D.log("telescope", "frequency loaded: %s", vim.inspect(frequency))
  return frequency
end

function popup_common.inc_frequency(name)
  frequency[name] = (frequency[name] or 0) + 1
  D.log("telescope", "new frequency: %s %d", name, frequency[name])
  vim.fn.writefile({ vim.fn.json_encode(frequency) }, frequency_file)
end

function popup_common.entry_maker(entry)
  return {
    value = entry.value,
    display = entry.label,
    ordinal = entry.label,
    frequency = frequency[entry.value] or 1,
  }
end

function popup_common.select(selection)
  vim.schedule(function()
    replacers.replace_selection(selection.value)
    state.restore_positions()
  end)
end

return popup_common
