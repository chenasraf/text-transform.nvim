local M = require("text-transform.main")
local TextTransform = {}

-- Toggle the plugin by calling the `enable`/`disable` methods respectively.
function TextTransform.toggle()
    -- when the config is not set to the global object, we set it
    if _G.TextTransform.config == nil then
        _G.TextTransform.config = require("text-transform.config").options
    end

    _G.TextTransform.state = M.toggle()
end

-- starts TextTransform and set internal functions and state.
function TextTransform.enable()
    if _G.TextTransform.config == nil then
        _G.TextTransform.config = require("text-transform.config").options
    end

    local state = M.enable()

    if state ~= nil then
        _G.TextTransform.state = state
    end

    return state
end

-- disables TextTransform and reset internal functions and state.
function TextTransform.disable()
    _G.TextTransform.state = M.disable()
end

-- setup TextTransform options and merge them with user provided ones.
function TextTransform.setup(opts)
    _G.TextTransform.config = require("text-transform.config").setup(opts)
end

_G.TextTransform = TextTransform

return _G.TextTransform
