local popup = {}

function popup.show_popup()
  local config = _G.TextTransform.config
  if config.popup_type == "telescope" then
    local telescope = require("text-transform.telescope")
    telescope.telescope_popup()
  else
    local select = require("text-transform.select")
    select.select_popup()
  end
end

return popup
