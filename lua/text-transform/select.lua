local common = require("text-transform.popup_common")
local state = require("text-transform.state")

local select = {}

function select.select_popup()
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

function select.show_popup()
  local config = _G.TextTransform.config
  if config.popup_type == "telescope" then
    select.telescope_popup()
  else
    select.select_popup()
  end
end

return select
