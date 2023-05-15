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

return TextTransform
