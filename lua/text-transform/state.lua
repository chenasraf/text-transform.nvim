local D = require("text-transform.util.debug")

local function ensure_config()
  -- when the config is not set to the global object, we set it
  if _G.TextTransform.config == nil then
    _G.TextTransform.config = require("text-transform.config").config
  end
end

-- methods
local TextTransform = {
  -- Boolean determining if the plugin is enabled or not.
  enabled = false,
  -- A table containing cursor position and visual selection details,
  -- saved using `save_position()` and can be restored using `restore_positions()`
  positions = nil,
}

--- Toggle the plugin by calling the `enable`/`disable` methods respectively.
--- @private
function TextTransform.toggle()
  if TextTransform.enabled then
    return TextTransform.disable()
  end

  return TextTransform.enable()
end

--- Enables the plugin
--- @private
function TextTransform.enable()
  ensure_config()

  if TextTransform.enabled then
    return TextTransform
  end

  TextTransform.enabled = true
  return TextTransform
end

---Disables the plugin and reset the internal state.
---@private
function TextTransform.disable()
  ensure_config()

  if not TextTransform.enabled then
    return TextTransform
  end

  -- reset the state
  TextTransform.enabled = false
  TextTransform.positions = nil
  return TextTransform
end

local function get_mode_type(mode)
  -- classify mode as either visual, line, block or normal
  local mode_map = {
    ["v"] = "visual",
    ["V"] = "line",
    ["\22"] = "block",
  }
  return mode_map[mode] or "normal"
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

--- Save the current cursor position, mode, and visual selection ranges
--- @private
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
    if mode == "block" then -- for block visual mode
      D.log("save_positions", "Visual mode is block, %s", vim.inspect({ visual_start, visual_end }))
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

  local state = {
    buf = buf,
    mode = mode,
    pos = pos,
    visual_start = visual_start,
    visual_end = visual_end,
  }

  D.log("save_positions", "State: %s", vim.inspect(state))
  TextTransform.positions = state
  return state
end

--- Restore the cursor position, mode, and visual selection ranges saved using `save_position()`,
--- or a given modified state, if passed as the first argument
function TextTransform.restore_positions(state)
  state = state or TextTransform.positions
  vim.api.nvim_set_current_buf(state.buf)
  vim.fn.setpos(".", state.pos)
  D.log("restore_positions", "Restored mode %s, cursor %s", state.mode, vim.inspect(state.pos))

  -- Attempt to restore visual mode accurately
  if
    (state.mode == "visual" or state.mode == "block")
    and state.visual_start
    and state.visual_end
  then
    vim.fn.setpos("'<", state.visual_start)
    vim.fn.setpos("'>", state.visual_end)
    local command = "normal! gv"
    vim.cmd(command)
    D.log("restore_positions", [[Restored visual mode %s using "%s"]], state.mode, command)
  end
  TextTransform.positions = nil
end

return TextTransform
