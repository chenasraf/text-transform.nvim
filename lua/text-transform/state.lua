local D = require("text-transform.util.debug")

local function ensure_config()
  -- when the config is not set to the global object, we set it
  if _G.TextTransform.config == nil then
    _G.TextTransform.config = require("text-transform.config").options
  end
end

-- methods
local State = {
  -- Boolean determining if the plugin is enabled or not.
  enabled = false,
  positions = nil,
}

---Toggle the plugin by calling the `enable`/`disable` methods respectively.
---@private
function State.toggle()
  if State.enabled then
    return State.disable()
  end

  return State.enable()
end

---Initializes the plugin.
---@private
function State.enable()
  ensure_config()

  if State.enabled then
    return State
  end

  State.enabled = true
  return State
end

---Disables the plugin and reset the internal state.
---@private
function State.disable()
  ensure_config()

  if not State.enabled then
    return State
  end

  -- reset the state
  State.enabled = false
  State.positions = nil
  return State
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

function State.save_positions()
  local buf = vim.api.nvim_get_current_buf()
  local mode_info = vim.api.nvim_get_mode()
  local mode = get_mode_type(mode_info.mode)
  local pos = vim.fn.getcurpos()
  -- leave mode
  local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "x", true)
  local visual_start = vim.fn.getpos("'<")
  local visual_end = vim.fn.getpos("'>")
  D.log("popup_menu", "Saved mode %s, cursor %s", mode, vim.inspect(pos))

  if mode == "visual" or mode == "line" or mode == "block" then
    if mode == "block" then -- for block visual mode
      D.log("popup_menu", "Visual mode is block, %s", vim.inspect({ visual_start, visual_end }))
      -- Adjust the positions to correctly capture the entire block
      visual_start = {
        visual_start[1],
        math.min(visual_start[2], visual_end[2]),
        visual_start[3],
        visual_start[4],
      }
      visual_end =
        { visual_end[1], math.max(visual_start[2], visual_end[2]), visual_end[3], visual_end[4] }
    end
    D.log(
      "popup_menu",
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

  D.log("popup_menu", "State: %s", vim.inspect(state))
  State.positions = state
  return state
end

function State.restore_positions(state)
  state = state or State.positions
  vim.api.nvim_set_current_buf(state.buf)
  vim.fn.setpos(".", state.pos)
  D.log("popup_menu", "Restored mode %s, cursor %s", state.mode, vim.inspect(state.pos))

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
    D.log("popup_menu", [[Restored visual mode %s using "%s"]], state.mode, command)
  end
  State.positions = nil
end

return State
