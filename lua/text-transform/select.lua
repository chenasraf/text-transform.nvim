local common = require("text-transform.popup_common")
local state = require("text-transform.state")

local select = {}

function select.select_popup()
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

return select
