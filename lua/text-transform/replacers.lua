local D = require("text-transform.utils.debug")
local state = require("text-transform.state")
local t = require("text-transform.transformers")

local TextTransform = {}

--- Finds the boundaries of the surrounding word around `start_col` within `line`.
--- @param line number
--- @param start_col number
--- @return number start_col, number end_col
local function find_word_boundaries(line, start_col)
  local line_text = vim.fn.getline(line)
  -- dashes, underscores, and periods are considered part of a word
  local word_pat = "[A-Za-z0-9_.\\-]"
  local non_word_pat = "[^A-Za-z0-9_.\\-]"
  -- TODO handle searching backwards
  local word_start_col = vim.fn.match(line_text:sub(start_col), word_pat) + start_col
  local word_end_col = vim.fn.match(line_text:sub(word_start_col), non_word_pat)
    + word_start_col
    - 1
  D.log(
    "find_word_boundaries",
    "Found word boundaries: %s",
    vim.inspect({ word_start_col, word_end_col })
  )
  D.log("find_word_boundaries", "Word text: %s", line_text:sub(word_start_col, word_end_col))
  D.log("find_word_boundaries", "Line text: %s", line_text)
  return word_start_col, word_end_col
end

--- Replace the range between the given positions with the given transform.
--- Acts on the lines between the given positions, replacing the text between the given columns.
---
--- @param start_line number The starting line
--- @param start_col number The starting column
--- @param end_line number The ending line
--- @param end_col number The ending column
--- @param transform_name string The transformer name
function TextTransform.replace_range(start_line, start_col, end_line, end_col, transform_name)
  D.log("replace_range", "Replacing range with %s", transform_name)
  local transform = t["to_" .. transform_name]
  local lines = vim.fn.getline(start_line, end_line) --- @type any
  local transformed = {}
  if #lines == 1 then
    local line = lines[1]
    local before = line:sub(0, start_col - 1)
    local fixed = transform(line:sub(start_col, end_col))
    local after = line:sub(end_col + 1)
    table.insert(transformed, before .. fixed .. after)
  else
    for i, line in ipairs(lines) do
      if i == 1 then
        table.insert(transformed, line:sub(1, start_col - 1) .. transform(line:sub(start_col)))
      elseif i == #lines then
        table.insert(transformed, transform(line:sub(1, end_col)) .. line:sub(end_col + 1))
      else
        table.insert(transformed, transform(line))
      end
    end
  end

  vim.fn.setline(start_line, transformed)
end

--- Replace the word under the cursor with the given transform.
--- If `position` is provided, replace the word under the given position.
--- Otherwise, attempts to find the word under the cursor.
---
--- @param transform_name string The transformer name
--- @param position table|nil A table containing the position of the word to replace
function TextTransform.replace_word(transform_name, position)
  D.log("replace_word", "Replacing word with %s", transform_name)
  local word, line, col, start_col, end_col
  if not position then
    word = vim.fn.expand("<cword>")
  else
    _, line, col = unpack(position)
    start_col, end_col = find_word_boundaries(line, col)
    word = vim.fn.getline(line):sub(start_col, end_col)
  end
  D.log("replace_word", "Found word %s", word)
  D.log("replace_word", "Using transformer %s", transform_name)
  local transformer = t["to_" .. transform_name]
  local transformed = transformer(word)
  D.log("replace_word", "New value %s", transformed)
  if not position then
    vim.cmd("normal ciw" .. transformed)
  else
    TextTransform.replace_range(line, start_col, line, end_col, transform_name)
  end
end

--- Replaces each column in visual block mode selection with the given transform.
--- Assumes that the each selection is 1 character and operates on the whole word under each cursor.
---
--- @param transform_name string The transformer name
function TextTransform.replace_columns(transform_name)
  local selections = TextTransform.get_visual_selection_details()
  D.log("replace_columns", "Replacing columns with %s", transform_name)
  for _, sel in ipairs(selections) do
    TextTransform.replace_word(transform_name, { 0, sel.start_line, sel.start_col, 0 })
  end
end

--- Replaces a selection with the given transform. This function attempts to infer the replacement
--- type based on the cursor positiono and visual selections, and passes information to relevant
--- range replacement functions.
---
--- @param transform_name string The transformer name
function TextTransform.replace_selection(transform_name)
  D.log("replace_selection", "Replacing selection with %s", transform_name)
  -- determine if cursor is a 1-width column across multiple lines  or a normal selection
  -- local start_line, start_col, end_line, end_col = unpack(vim.fn.getpos("'<"))
  local selections = TextTransform.get_visual_selection_details()

  D.log("replace_selection", "Selections: %s", vim.inspect(selections))
  local is_multiline = #selections > 1
  local is_column = is_multiline and selections[1].start_col == selections[#selections].end_col
  local is_single_cursor = not is_multiline
    and not is_column
    and selections
    and selections[1]
    and selections[1].start_col == selections[1].end_col

  D.log(
    "replace_selection",
    "is_multiline: %s, is_column: %s, is_word: %s",
    is_multiline,
    is_column,
    is_single_cursor
  )

  if is_single_cursor then
    TextTransform.replace_word(transform_name)
  elseif is_column then
    TextTransform.replace_columns(transform_name)
  else
    for _, sel in pairs(selections) do
      TextTransform.replace_range(
        sel.start_line,
        sel.start_col,
        sel.end_line,
        sel.end_col,
        transform_name
      )
    end
  end
end

--- Takes the saved positions and translates them into individual visual ranges, regardless of how
--- the original selection was performed.
---
--- This allows to treat all ranges equally and allows to work on each selection without knowing
--- the full information around the selection logic.
function TextTransform.get_visual_selection_details()
  if not state.state.positions then
    D.log("get_visual_selection_details", "No positions saved")
    return {}
  end
  D.log(
    "get_visual_selection_details",
    "Getting visual selection details - mode: %s, is_visual: %s, is_block: %s",
    state.state.positions.mode,
    state.is_visual_mode(),
    state.is_block_visual_mode()
  )

  -- Get the start and end positions of the selection
  local start_pos = state.state.positions.visual_start
  local end_pos = state.state.positions.visual_end
  local start_line, start_col = start_pos[2], start_pos[3]
  local end_line, end_col = end_pos[2], end_pos[3]

  -- Check if currently in visual mode; if not, return the cursor position
  if
    not state.is_visual_mode()
    and not state.is_block_visual_mode()
    and not state.has_range(start_pos, end_pos)
  then
    local pos = state.positions.pos
    D.log("get_visual_selection_details", "Returning single cursor position")
    return {
      {
        start_line = pos[2],
        end_line = pos[2],
        start_col = pos[3],
        end_col = pos[3],
      },
    }
  end

  -- Swap if selection is made upwards or backwards
  if start_line > end_line or (start_line == end_line and start_col > end_col) then
    start_line, end_line = end_line, start_line
    start_col, end_col = end_col, start_col
  end

  -- If it's block visual mode, return table for each row
  if state.is_block_visual_mode() or state.has_range(start_pos, end_pos) then
    local block_selection = {}
    for line = start_line, end_line do
      if start_col == end_col then
        -- find the word surrounding the position
        start_col, _ = find_word_boundaries(line, start_col)
      end
      table.insert(block_selection, {
        start_line = line,
        end_line = line,
        start_col = start_col,
        end_col = start_col,
      })
    end
    D.log(
      "get_visual_selection_details",
      "Returning block selection: %s",
      vim.inspect(block_selection)
    )
    return block_selection
  else
    -- Normal visual mode, return single table entry
    D.log("get_visual_selection_details", "Returning normal selection")
    return {
      {
        start_line = start_line,
        end_line = end_line,
        start_col = start_col,
        end_col = end_col,
      },
    }
  end
end

return TextTransform
