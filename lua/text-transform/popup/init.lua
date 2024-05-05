local popup = {}

--- Pops up a selection menu, containing the available case transformers.
--- When a transformer is selected, the cursor position/range/columns will be used to replace the
--- words around the cursor or inside the selection.
---
--- The cursor positions/ranges are saved before opening the menu and restored once a selection is
--- made.
function popup.show_popup()
  local config = _G.TextTransform.config
  if config.popup_type == "telescope" then
    local telescope = require("text-transform.popup.telescope")
    telescope.telescope_popup()
  else
    local select = require("text-transform.popup.select")
    select.select_popup()
  end
end

return popup
