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
T["setup()"] = MiniTest.new_set()

T["setup()"]["sets exposed methods and default options value"] = function()
  child.lua([[require('text-transform').setup()]])

  -- global object that holds your plugin information
  eq_type_global(child, "_G.TextTransform", "table")

  -- public methods
  eq_type_global(child, "_G.TextTransform.toggle", "function")
  eq_type_global(child, "_G.TextTransform.disable", "function")
  eq_type_global(child, "_G.TextTransform.enable", "function")

  -- config
  eq_type_global(child, "_G.TextTransform.config", "table")

  -- assert the value, and the type
  eq_type_config(child, "debug", "boolean")
  eq_config(child, "debug", false)

  eq_type_config(child, "keymap", "table")

  eq_type_config(child, "keymap.v", "string")
  eq_config(child, "keymap.v", "<Leader>~")

  eq_type_config(child, "keymap.n", "string")
  eq_config(child, "keymap.n", "<Leader>~")
end

T["setup()"]["overrides default values"] = function()
  child.lua([[require('text-transform').setup({
        -- write all the options with a value different than the default ones
        debug = true,
        keymap = {
          ["v"] = "<leader>c",
          ["n"] = "<leader>c",
        },
    })]])

  -- assert the value, and the type
  eq_type_config(child, "debug", "boolean")
  eq_config(child, "debug", true)

  eq_type_config(child, "keymap", "table")

  eq_type_config(child, "keymap.v", "string")
  eq_config(child, "keymap.v", "<leader>c")

  eq_type_config(child, "keymap.n", "string")
  eq_config(child, "keymap.n", "<leader>c")
end

return T
