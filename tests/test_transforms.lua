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
    { "hello.world", "helloWorld" },
    { "hello", "hello" },
    { "helloWorld123", "helloWorld123" },
  },
  ["snake_case"] = {
    { "helloWorld", "hello_world" },
    { "hello world", "hello_world" },
    { "hello-world", "hello_world" },
    { "hello.world", "hello_world" },
    { "hello", "hello" },
    { "helloWorld123", "hello_world_123" },
  },
  ["pascal_case"] = {
    { "hello_world", "HelloWorld" },
    { "hello world", "HelloWorld" },
    { "hello-world", "HelloWorld" },
    { "hello.world", "HelloWorld" },
    { "hello", "Hello" },
    { "helloWorld123", "HelloWorld123" },
  },
  ["kebab_case"] = {
    { "helloWorld", "hello-world" },
    { "hello world", "hello-world" },
    { "hello-world", "hello-world" },
    { "hello.world", "hello-world" },
    { "hello", "hello" },
    { "helloWorld123", "hello-world-123" },
  },
  ["dot_case"] = {
    { "helloWorld", "hello.world" },
    { "hello world", "hello.world" },
    { "hello-world", "hello.world" },
    { "hello.world", "hello.world" },
    { "hello", "hello" },
    { "helloWorld123", "hello.world.123" },
  },
  ["const_case"] = {
    { "helloWorld", "HELLO_WORLD" },
    { "hello world", "HELLO_WORLD" },
    { "hello-world", "HELLO_WORLD" },
    { "hello.world", "HELLO_WORLD" },
    { "hello", "HELLO" },
    { "helloWorld123", "HELLO_WORLD_123" },
  },
  ["title_case"] = {
    { "helloWorld", "Hello World" },
    { "hello world", "Hello World" },
    { "hello-world", "Hello World" },
    { "hello.world", "Hello World" },
    { "hello", "Hello" },
    { "helloWorld123", "Hello World 123" },
  },
}

for fn_name, cases in pairs(map) do
  T[fn_name .. "()"] = MiniTest.new_set()
  for _, case in ipairs(cases) do
    local input, output = unpack(case)
    T[fn_name .. "()"]["input: " .. input] = make_transform_test(fn_name, input, output)
  end
end

return T
