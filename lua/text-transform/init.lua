local M = require("text-transform.main")
local utils = require("text-transform.utils")

local TextTransform = {}

function TextTransform.setup(opts)
  _G.TextTransform.config = require("text-transform.config").setup(opts)
end

_G.TextTransform = utils.merge(M, TextTransform)

return _G.TextTransform
