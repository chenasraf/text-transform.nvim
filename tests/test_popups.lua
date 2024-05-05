local helpers = dofile("tests/helpers.lua")
local MiniTest = require("mini.test")

-- See https://github.com/echasnovski/mini.nvim/blob/main/lua/mini/test.lua for more documentation

local child = helpers.new_child_neovim()
local eq_global, eq_config, eq_state =
  helpers.expect.global_equality, helpers.expect.config_equality, helpers.expect.state_equality
local eq_type_global, eq_type_config, eq_type_state =
  helpers.expect.global_type_equality,
  helpers.expect.config_type_equality,
  helpers.expect.state_type_equality

local T = MiniTest.new_set({
  hooks = {
    -- This will be executed before every (even nested) case
    pre_case = function()
      -- Restart child process with custom 'init.lua' script
      child.restart({ "-u", "scripts/minimal_init.lua" })
    end,
    -- This will be executed one after all tests from this set are finished
    post_once = child.stop,
  },
})

-- Tests related to the `setup` method.
T["popups"] = MiniTest.new_set()

T["popups"]["exposes show_popup"] = function()
  helpers.init_plugin(child)

  eq_type_global(child, "_G.TextTransform", "table")

  eq_type_global(child, "_G.TextTransform.show_popup", "function")

  eq_type_global(child, "_G.TextTransform.telescope_popup", "nil")
end

T["popups"]["telescope exposes telescope_popup"] = function()
  helpers.init_plugin(child)

  eq_type_global(child, "_G.TextTransform", "table")

  eq_type_global(child, "_G.TextTransform.telescope_popup", "nil")

  child.lua([[Telescope = require('text-transform.popup.telescope')]])

  eq_type_global(child, "Telescope.telescope_popup", "function")
end

T["popups"]["select exposes select_popup"] = function()
  helpers.init_plugin(child)

  eq_type_global(child, "_G.TextTransform", "table")

  eq_type_global(child, "_G.TextTransform.select_popup", "nil")

  child.lua([[Select = require('text-transform.popup.select')]])

  eq_type_global(child, "Select.select_popup", "function")
end

return T
