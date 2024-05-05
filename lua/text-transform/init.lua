local utils = require("text-transform.utils")
local tt = require("text-transform.transformers")
local replacers = require("text-transform.replacers")
local state = require("text-transform.state")
local popup = require("text-transform.popup")

local TextTransform = {}

function TextTransform.setup(opts)
  _G.TextTransform.config = require("text-transform.config").setup(opts)
end

local function merge(table)
  TextTransform = utils.merge(TextTransform, table)
end

merge(tt)
merge(replacers)
merge(state)
merge(popup)

_G.TextTransform = TextTransform
return _G.TextTransform
