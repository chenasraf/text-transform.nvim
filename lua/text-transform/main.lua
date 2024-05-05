local utils = require("text-transform.utils")
local tt = require("text-transform.transformers")
local replacers = require("text-transform.replacers")
local state = require("text-transform.state")
local popup = require("text-transform.popup")

local TextTransform = {}

local function merge(table)
  TextTransform = utils.merge(TextTransform, table)
end

merge(tt)
merge(replacers)
merge(state)
merge(popup)

return TextTransform
