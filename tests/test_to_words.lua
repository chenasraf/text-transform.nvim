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

local function test_string(child, str)
  helpers.init_plugin(child)
  child.lua([[result = require('text-transform').to_words("]] .. str .. [[")]])
end

T["to_words()"] = MiniTest.new_set()

T["to_words()"]["should split normal spaced words"] = function()
  test_string(child, "hello world")
  eq_type_global(child, "result", "table")
  eq_global(child, "result", { "hello", "world" })
end

T["to_words()"]["should split camel case strings"] = function()
  test_string(child, "helloWorld")
  eq_type_global(child, "result", "table")
  eq_global(child, "result", { "hello", "world" })
end

T["to_words()"]["should split dot case strings"] = function()
  test_string(child, "hello.world")
  eq_type_global(child, "result", "table")
  eq_global(child, "result", { "hello", "world" })
end

T["to_words()"]["should split const case strings"] = function()
  test_string(child, "HELLO_WORLD")
  eq_type_global(child, "result", "table")
  eq_global(child, "result", { "hello", "world" })
end

T["to_words()"]["should treat numbers as words"] = function()
  test_string(child, "helloWorld123")
  eq_type_global(child, "result", "table")
  eq_global(child, "result", { "hello", "world", "123" })
end

T["to_words()"]["should trim trailing/leading"] = function()
  test_string(child, "  hello world  ")
  eq_type_global(child, "result", "table")
  eq_global(child, "result", { "hello", "world" })
end

return T
