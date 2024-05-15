local D = {}

local function is_debug()
  return _G.TextTransform ~= nil
    and _G.TextTransform.config ~= nil
    and _G.TextTransform.config.debug
end

function D.log(scope, str, ...)
  if not is_debug() then
    return
  end

  local info = debug.getinfo(2, "Sl")
  local line = ""

  if info then
    line = "L" .. info.currentline
  end

  print(
    string.format(
      "%s [text-transform:%s in %s] > %s",
      os.date("%H:%M:%S"),
      scope,
      line,
      string.format(str, ...)
    )
  )
end

function D.tprint(table, indent)
  if not is_debug() then
    return
  end

  if not indent then
    indent = 0
  end

  for k, v in pairs(table) do
    local formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      D.tprint(v, indent + 1)
    elseif type(v) == "boolean" then
      print(formatting .. tostring(v))
    elseif type(v) == "function" then
      print(formatting .. "FUNCTION")
    else
      print(formatting .. v)
    end
  end
end

return D
