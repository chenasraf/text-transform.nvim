local D = require("text-transform.util.debug")
local utils = require("text-transform.util")

local fn = {}

fn.WORD_BOUNDRY = '[%_%-%s%.]'

--- Splits a string into words.
--- @param string string
--- @return table
function fn.to_words(string)
  local words = {}
  local word = ''
  for i = 1, #string do
    local char = string:sub(i, i)
    if char:match(fn.WORD_BOUNDRY) then
      if word ~= '' then
        table.insert(words, word:lower())
      end
      word = ''
    else
      word = word .. char
      -- word = word .. string:sub(i)
      -- break
    end
    D.log('transformers', 'i %d char %s word %s words %s', i, char, word, utils.dump(words))
  end
  if word ~= '' then
    table.insert(words, word:lower())
  end
  D.log('transformers', 'words %s', vim.inspect(words))
  return words
end

--- Transforms a table of strings into a string using a callback and separator.
--- The callback is called with the word, the index, and the table of words.
--- The separator is added between each word.
---
--- @param words table of strings
--- @param with_word_cb function (word: string, index: number, words: table) -> string
--- @param separator string|nil (optional)
--- @return string
function fn.transform_words(words, with_word_cb, separator)
  local out = ''
  for i, word in ipairs(words) do
    local new_word = with_word_cb(word, i, word)
    out = out .. new_word
    if separator and i > 1 then
      out = out .. separator
    end
    D.log('transformers', 'word %s new_word %s out %s', word, new_word, out)
  end
  return out
end

--- Transforms a string into camelCase.
--- @param string string
--- @return string
function fn.to_camel_case(string)
  return fn.transform_words(fn.to_words(string), function(word, i)
    if i == 1 then
      return word:lower()
    end
    return word:sub(1, 1):upper() .. word:sub(2):lower()
  end)
end

--- Transfroms a string into snake_case.
--- @param string any
--- @return string
function fn.to_snake_case(string)
  return fn.transform_words(fn.to_words(string), function(word, i)
    if i == 1 then
      return word:lower()
    end
    return word:lower()
  end, '_')
end

--- Transforms a string into PascalCase.
--- @param string string
--- @return string
function fn.to_pascal_case(string)
  local cc = fn.to_camel_case(string)
  return cc:sub(1, 1):upper() .. cc:sub(2)
end

--- Transforms a string into Title Case.
--- @param string string
--- @return string
function fn.to_title_case(string)
  return fn.transform_words(fn.to_words(string), function(word)
    return word:sub(1, 1):upper() .. word:sub(2):lower()
  end, ' ')
end

--- Transforms a string into kebab-case.
--- @param string string
--- @return string
function fn.to_kebab_case(string)
  return fn.transform_words(fn.to_words(string), function(word)
    return word:lower()
  end, '-')
end

--- Transforms a string into dot.case.
--- @param string string
--- @return string
function fn.to_dot_case(string)
  return fn.transform_words(fn.to_words(string), function(word)
    return word:lower()
  end, '.')
end

--- Transforms a string into CONSTANT_CASE.
--- @param string string
--- @return string
function fn.to_const_case(string)
  return fn.transform_words(fn.to_words(string), function(word)
    return word:upper()
  end, '_')
end

return fn
