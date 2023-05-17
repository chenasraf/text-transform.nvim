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

local map = {
  ["camel_case"] = {
    { "hello_world", "helloWorld" },
    { "hello world", "helloWorld" },
    { "hello-world", "helloWorld" },
    -- { "hello.world", "helloWorld" },
    { "hello", "hello" },
    { "helloWorld123", "helloWorld123" },
  },
  ["snake_case"] = { { "helloWorld", "hello_world" } },
  ["pascal_case"] = { { "hello_world", "HelloWorld" } },
  ["kebab_case"] = { { "helloWorld", "hello-world" } },
  ["dot_case"] = { { "helloWorld", "hello.world" } },
  ["const_case"] = { { "helloWorld", "HELLO_WORLD" } },
  ["title_case"] = { { "helloWorld", "Hello World" } },
}

for fn_name, cases in pairs(map) do
  T[fn_name .. "()"] = MiniTest.new_set()
  for _, case in ipairs(cases) do
    local input, output = unpack(case)
    T[fn_name .. "()"]["input: " .. input] = make_transform_test(fn_name, input, output)
  end
end

return T
