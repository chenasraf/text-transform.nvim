local D = require("text-transform.utils.debug")

-- methods
local state = {
  -- A table containing cursor position and visual selection details,
  -- saved using `save_position()` and can be restored using `restore_positions()`
  positions = nil,
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

function state.has_range(visual_start, visual_end)
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

function state.is_block_visual_mode()
  return state.positions.mode == "block"
  -- return vim.fn.mode() == "V" or vim.fn.mode() == "\22"
end

function state.is_visual_mode()
  return state.positions.mode == "visual"
  -- return vim.fn.mode() == 'v'
end

--- Save the current cursor position, mode, and visual selection ranges
function state.save_positions()
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
    if state.has_range(visual_start, visual_end) then -- for ranges
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
  state.positions = positions
  return positions
end

--- Restore the cursor position, mode, and visual selection ranges saved using `save_position()`,
--- or a given modified state, if passed as the first argument
function state.restore_positions(new_state)
  new_state = new_state or new_state.positions
  vim.api.nvim_set_current_buf(new_state.buf)
  vim.fn.setpos(".", new_state.pos)
  D.log(
    "restore_positions",
    "Restored mode %s, cursor %s",
    new_state.mode,
    vim.inspect(new_state.pos)
  )

  -- Attempt to restore visual mode accurately
  if
    (new_state.mode == "visual" or new_state.mode == "block")
    and new_state.visual_start
    and new_state.visual_end
  then
    vim.fn.setpos("'<", new_state.visual_start)
    vim.fn.setpos("'>", new_state.visual_end)
    local command = "normal! gv"
    vim.cmd(command)
    D.log("restore_positions", [[Restored visual mode %s using "%s"]], new_state.mode, command)
  end
  new_state.positions = nil
end

return state
