local helpers = dofile("tests/helpers.lua")

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
  eq_config(child, "debug", false)
  eq_type_config(child, "debug", "boolean")

  eq_type_config(child, "keymap", "table")

  eq_config(child, "keymap.v", "<Leader>~")
  eq_type_config(child, "keymap.v", "string")

  eq_config(child, "keymap.n", "<Leader>~")
  eq_type_config(child, "keymap.n", "string")
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

  eq_config(child, "keymap.v", "<leader>c")
  eq_type_config(child, "keymap.v", "string")

  eq_config(child, "keymap.n", "<leader>c")
  eq_type_config(child, "keymap.n", "string")
end

local function make_transform_test(fn_name, input, expected)
  return function()
    child.lua([[require('text-transform').setup()]])
    child.lua([[result = require('text-transform').]] .. fn_name .. '("' .. input .. '")')
    eq_global(child, "result", expected)
  end
end

T["camel_case()"] = MiniTest.new_set()
T["camel_case()"]["transforms string"] =
  make_transform_test("camel_case", "hello_world", "helloWorld")

T["snake_case()"] = MiniTest.new_set()
T["snake_case()"]["transforms string"] =
  make_transform_test("snake_case", "helloWorld", "hello_world")

T["pascal_case()"] = MiniTest.new_set()
T["pascal_case()"]["transforms string"] =
  make_transform_test("pascal_case", "hello_world", "HelloWorld")

T["kebab_case()"] = MiniTest.new_set()
T["kebab_case()"]["transforms string"] =
  make_transform_test("kebab_case", "helloWorld", "hello-world")

T["dot_case()"] = MiniTest.new_set()
T["dot_case()"]["transforms string"] = make_transform_test("dot_case", "helloWorld", "hello.world")

T["const_case()"] = MiniTest.new_set()
T["const_case()"]["transforms string"] =
  make_transform_test("const_case", "helloWorld", "HELLO_WORLD")

T["title_case()"] = MiniTest.new_set()
T["title_case()"]["transforms string"] =
  make_transform_test("title_case", "helloWorld", "Hello World")
return T
