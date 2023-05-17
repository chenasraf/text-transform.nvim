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

T["into_words()"] = MiniTest.new_set()

T["into_words()"]["should split two words with spaces"] = function()
  child.lua([[require('text-transform').setup()]])
  child.lua([[result = require('text-transform').into_words("hello world")]])
  eq_type_global(child, "result", "table")
  eq_global(child, "result[1]", "hello")
  eq_global(child, "result[2]", "world")
end

T["into_words()"]["should split two words with no spaces"] = function()
  child.lua([[require('text-transform').setup()]])
  child.lua([[result = require('text-transform').into_words("helloWorld")]])
  eq_type_global(child, "result", "table")
  eq_global(child, "result[1]", "hello")
  eq_global(child, "result[2]", "world")
end

T["into_words()"]["should split two words with dots"] = function()
  child.lua([[require('text-transform').setup()]])
  child.lua([[result = require('text-transform').into_words("hello.world")]])
  eq_type_global(child, "result", "table")
  eq_global(child, "result[1]", "hello")
  eq_global(child, "result[2]", "world")
end

T["into_words()"]["should split two words with a number inside"] = function()
  child.lua([[require('text-transform').setup()]])
  child.lua([[result = require('text-transform').into_words("helloWorld123")]])
  eq_type_global(child, "result", "table")
  eq_global(child, "result[1]", "hello")
  eq_global(child, "result[2]", "world")
  eq_global(child, "result[3]", "123")
end

T["into_words()"]["should split two words and ignore trailing/leading spaces"] = function()
  child.lua([[require('text-transform').setup()]])
  child.lua([[result = require('text-transform').into_words("  hello world  ")]])
  eq_type_global(child, "result", "table")
  eq_global(child, "result[1]", "hello")
  eq_global(child, "result[2]", "world")
end

return T
