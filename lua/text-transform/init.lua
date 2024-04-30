local D = require("text-transform.util.debug")
local TextTransform = require("text-transform.main")

--- Setup TextTransform options and merge them with user provided ones.
function TextTransform.setup(opts)
  _G.TextTransform.config = require("text-transform.config").setup(opts)
end

_G.TextTransform = TextTransform

return _G.TextTransform
