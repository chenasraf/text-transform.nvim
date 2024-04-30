local utils = require("text-transform.util")
local tt = require("text-transform.transformers")
local replacers = require("text-transform.replacers")
local state = require("text-transform.state")

local TextTransform = {}

local function merge(table)
  TextTransform = utils.merge(TextTransform, table)
end

merge(tt)
merge(replacers)
merge(state)
-- TextTransform.state = state

return TextTransform
