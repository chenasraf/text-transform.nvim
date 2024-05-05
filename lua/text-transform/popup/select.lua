local common = require("text-transform.popup.common")
local state = require("text-transform.state")

local TextTransform = {}

--- Pops up a selection menu, containing the available case transformers.
--- When a transformer is selected, the cursor position/range/columns will be used to replace the
--- words around the cursor or inside the selection.
---
--- The cursor positions/ranges are saved before opening the menu and restored once a selection is
--- made.
function TextTransform.select_popup()
  common.load_frequency()
  state.save_positions()

  vim.ui.select(common.items, {
    prompt = "Change Case",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if not choice then
      return
    end
    local item = common.entry_maker(choice)
    common.select(item)
  end)
end

return TextTransform
