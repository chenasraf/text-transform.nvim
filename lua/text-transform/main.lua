local D = require("text-transform.util.debug")

-- internal methods
local TextTransform = {}

-- state
local S = {
  -- Boolean determining if the plugin is enabled or not.
  enabled = false,
}

---Toggle the plugin by calling the `enable`/`disable` methods respectively.
---@private
function TextTransform.toggle()
  if S.enabled then
    return TextTransform.disable()
  end

  return TextTransform.enable()
end

---Initializes the plugin.
---@private
function TextTransform.enable()
  if S.enabled then
    return S
  end

  S.enabled = true

  return S
end

---Disables the plugin and reset the internal state.
---@private
function TextTransform.disable()
  if not S.enabled then
    return S
  end

  -- reset the state
  S = {
    enabled = false,
  }

  return S
end

--- Splits a string into words.
function TextTransform.into_words(str)
  local words = {}
  local word = ""

  local previous_is_split_token = false
  for i = 1, #str do
    local char = str:sub(i, i)
    local is_upper = char:match("%u")
    local is_num = char:match("%d")
    local is_separator = char:match("[%_%-%s%.]")
    local is_split_token = is_upper or is_num
    -- split on uppercase letters or numbers
    if is_split_token and not previous_is_split_token then
      if word ~= "" then
        table.insert(words, word:lower())
      end
      previous_is_split_token = true
      word = char
      -- split on underscores, hyphens, and spaces
    elseif is_separator then
      if word ~= "" then
        table.insert(words, word:lower())
        previous_is_split_token = false
      end
      word = ""
    else
      word = word .. char
      previous_is_split_token = is_split_token
    end
  end
  if word ~= "" then
    table.insert(words, word:lower())
    previous_is_split_token = false
  end
  return words
end

--- Transforms a string into camelCase.
function TextTransform.camel_case(string)
  local words = TextTransform.into_words(string)
  local camel_case = ""
  for i, word in ipairs(words) do
    if i == 1 then
      camel_case = camel_case .. word:lower()
    else
      camel_case = camel_case .. word:sub(1, 1):upper() .. word:sub(2):lower()
    end
  end
  return camel_case
end

--- Transforms a string into snake_case.
function TextTransform.snake_case(string)
  local words = TextTransform.into_words(string)
  local snake_case = ""
  for i, word in ipairs(words) do
    if i == 1 then
      snake_case = snake_case .. word:lower()
    else
      snake_case = snake_case .. "_" .. word:lower()
    end
  end
  return snake_case
end

--- Transforms a string into PascalCase.
function TextTransform.pascal_case(string)
  local words = TextTransform.into_words(string)
  local pascal_case = ""
  for _, word in ipairs(words) do
    pascal_case = pascal_case .. word:sub(1, 1):upper() .. word:sub(2):lower()
  end
  return pascal_case
end

--- Transforms a string into kebab-case.
function TextTransform.kebab_case(string)
  local words = TextTransform.into_words(string)
  local kebab_case = ""
  for i, word in ipairs(words) do
    if i == 1 then
      kebab_case = kebab_case .. word:lower()
    else
      kebab_case = kebab_case .. "-" .. word:lower()
    end
  end
  return kebab_case
end

--- Transforms a string into dot.case.
function TextTransform.dot_case(string)
  local words = TextTransform.into_words(string)
  local dot_case = ""
  for i, word in ipairs(words) do
    if i == 1 then
      dot_case = dot_case .. word:lower()
    else
      dot_case = dot_case .. "." .. word:lower()
    end
  end
  return dot_case
end

--- Transforms a string into Title Case.
function TextTransform.title_case(string)
  local words = TextTransform.into_words(string)
  local title_case = ""
  for i, word in ipairs(words) do
    title_case = title_case .. word:sub(1, 1):upper() .. word:sub(2):lower()
    if i ~= #words then
      title_case = title_case .. " "
    end
  end
  return title_case
end

--- Transforms a string into CONSTANT_CASE.
function TextTransform.const_case(string)
  local words = TextTransform.into_words(string)
  local const_case = ""
  for i, word in ipairs(words) do
    if i == 1 then
      const_case = const_case .. word:upper()
    else
      const_case = const_case .. "_" .. word:upper()
    end
  end
  return const_case
end

--- Replaces the text at the given position with the given transform.
function TextTransform.replace_at(start_line, start_col, end_line, end_col, transform)
  -- use the arguments to replace at the position
  local lines = vim.fn.getline(start_line, end_line)
  local transformed = ""
  if #lines == 1 then
    transformed = lines[1]:sub(1, start_col - 1)
      .. TextTransform[transform](lines[1]:sub(start_col, end_col))
      .. lines[1]:sub(end_col + 1)
  else
    transformed = lines[1]:sub(1, start_col - 1)
      .. TextTransform[transform](lines[1]:sub(start_col))
      .. "\n"
    for i = 2, #lines - 1 do
      transformed = transformed .. TextTransform[transform](lines[i]) .. "\n"
    end
    transformed = transformed
      .. TextTransform[transform](lines[#lines]:sub(1, end_col))
      .. lines[#lines]:sub(end_col + 1)
  end

  -- replace the lines with the transformed lines
  vim.fn.setline(start_line, transformed)
  for i = start_line + 1, end_line do
    vim.fn.setline(i, "")
  end
end

--- Replaces the current word with the given transform.
function TextTransform.replace_word(transform)
  local word = vim.fn.expand("<cword>")
  local transformed = TextTransform[transform](word)
  vim.cmd("normal ciw" .. transformed)
end

--- Replaces each column in visual block mode selection with the given transform.
--- Assumes that the each selection is 1 character and operates on the whole word under each cursor.
function TextTransform.replace_columns(transform)
  -- get all the multiple cursor positions
  local _, start_line, start_col = unpack(vim.fn.getpos("'<"))
  local _, end_line = unpack(vim.fn.getpos("'>"))

  D.tprint({ start_line, start_col, end_line })

  -- for each cursor start_col, find the word under the cursor and transform it
  for line_num = start_line, end_line do
    -- get the line of this cursor
    local line = vim.fn.getline(line_num)
    -- match the surrounding word using start_col
    local word = line:match("[%w%_%-%.]+", start_col)
    -- replace the word with the transformed word
    TextTransform.replace_cursor_range(line_num, start_col, start_col + #word, transform)
  end
end

--- Replaces each cursor selection range with the given transform.
function TextTransform.replace_cursor_range(line, start_col, end_col, transform)
  return TextTransform.replace_at(line, start_col, line, end_col, transform)
end

function TextTransform.replace_selection(transform)
  -- determine if cursor is a 1-length column or a normal selection
  local is_column = vim.fn.getpos("'<")[2] == vim.fn.getpos("'>")[2]

  if is_column then
    TextTransform.replace_columns(transform)
  else
    local _, start_line, start_col, end_col = unpack(vim.fn.getpos("'<"))
    TextTransform.replace_cursor_range(start_line, start_col, end_col, transform)
  end
end

return TextTransform
