local D = require("text-transform.utils.debug")

-- methods
local TextTransform = {
  -- The current state of the plugin
  state = {
    -- A table containing cursor position and visual selection details,
    -- saved using `save_position()` and can be restored using `restore_positions()`
    --@type {buf: number, mode: string, pos: table, visual_start: table, visual_end: table}
    positions = {},
  },
}

local function get_mode_type(mode)
  -- classify mode as either visual, line, block or normal
  local mode_map = {
    ["v"] = "visual",
    ["V"] = "line",
    ["\22"] = "block",
  }
  return mode_map[mode] or "normal"
end

function TextTransform.has_range(visual_start, visual_end)
  return visual_start and visual_end and visual_start[2] ~= visual_end[2]
end

local function capture_part(start_sel, end_sel, return_type)
  local l, sel
  if return_type == "start" then
    l = math.min(start_sel[2], end_sel[2])
    sel = start_sel
  else
    l = math.max(start_sel[2], end_sel[2])
    sel = end_sel
  end
  return { sel[1], l, sel[3], sel[4] }
end

function TextTransform.is_block_visual_mode()
  return TextTransform.state.positions.mode == "block"
  -- return vim.fn.mode() == "V" or vim.fn.mode() == "\22"
end

function TextTransform.is_visual_mode()
  return TextTransform.state.positions.mode == "visual"
  -- return vim.fn.mode() == 'v'
end

--- Save the current cursor position, mode, and visual selection ranges
function TextTransform.save_positions()
  local buf = vim.api.nvim_get_current_buf()
  local mode_info = vim.api.nvim_get_mode()
  local mode = get_mode_type(mode_info.mode)
  local pos = vim.fn.getcurpos()
  -- leave mode, required to get the positions - they only register on mode leave
  -- in case of visual mode
  local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "x", true)
  local visual_start = vim.fn.getpos("'<")
  local visual_end = vim.fn.getpos("'>")
  D.log("save_positions", "Saved mode %s, cursor %s", mode, vim.inspect(pos))

  if mode == "visual" or mode == "line" or mode == "block" then
    if TextTransform.has_range(visual_start, visual_end) then -- for ranges
      D.log(
        "save_positions",
        "Visual range, mode is %s, %s",
        mode,
        vim.inspect({ visual_start, visual_end })
      )
      -- Adjust the positions to correctly capture the entire block
      visual_start = capture_part(visual_start, visual_end, "start")
      visual_end = capture_part(visual_start, visual_end, "end")
    end
    D.log(
      "state",
      "Saved visual mode %s, cursor %s",
      mode,
      vim.inspect({ visual_start, visual_end })
    )
  end

  local positions = {
    buf = buf,
    mode = mode,
    pos = pos,
    visual_start = visual_start,
    visual_end = visual_end,
  }

  D.log("save_positions", "State: %s", vim.inspect(positions))
  TextTransform.state.positions = positions
  return positions
end

--- Restore the cursor position, mode, and visual selection ranges saved using `save_position()`,
--- or a given modified state, if passed as the first argument
function TextTransform.restore_positions(positions)
  positions = positions or TextTransform.state.positions
  vim.api.nvim_set_current_buf(positions.buf)
  vim.fn.setpos(".", positions.pos)
  D.log(
    "restore_positions",
    "Restored mode %s, cursor %s",
    positions.mode,
    vim.inspect(positions.pos)
  )

  -- Attempt to restore visual mode accurately
  if
    (positions.mode == "visual" or positions.mode == "block")
    and positions.visual_start
    and positions.visual_end
  then
    vim.fn.setpos("'<", positions.visual_start)
    vim.fn.setpos("'>", positions.visual_end)
    local command = "normal! gv"
    vim.cmd(command)
    D.log("restore_positions", [[Restored visual mode %s using "%s"]], positions.mode, command)
  end

  TextTransform.state.positions = {}
end

return TextTransform
