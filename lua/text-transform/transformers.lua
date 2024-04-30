local D = require("text-transform.util.debug")
local utils = require("text-transform.util")

local TextTransform = {}

TextTransform.WORD_BOUNDRY = "[%_%-%s%.]"

--- Splits a string into words.
--- @param string string
--- @return table
function TextTransform.to_words(string)
  local words = {}
  local word = ""
  local last_is_upper = false
  local last_is_digit = false
  for i = 1, #string do
    local char = string:sub(i, i)
    if char:match(TextTransform.WORD_BOUNDRY) then
      if word ~= "" then
        table.insert(words, word:lower())
      end
      word = ""
    else
      if
        (char:match("%d") and not last_is_digit)
        or (char:match("%u") and not last_is_upper and word ~= "")
        or (char:match("%l") and last_is_digit)
      then
        if word ~= "" then
          table.insert(words, word:lower())
          word = ""
        end
      end

      -- Update flags based on current character type
      if char:match("%d") then
        last_is_digit = true
        last_is_upper = false
      elseif char:match("%u") then
        last_is_upper = true
        last_is_digit = false
      else -- Lowercase or any non-digit/non-uppercase
        last_is_upper = false
        last_is_digit = false
      end

      -- Append current character to the current word
      word = word .. char
    end
    D.log("transformers", "i %d char %s word %s words %s", i, char, word, utils.dump(words))
  end
  if word ~= "" then
    table.insert(words, word:lower())
  end
  D.log("transformers", "words %s", vim.inspect(words))
  return words
end

--- Transforms a table of strings into a string using a callback and separator.
--- The callback is called with the word, the index, and the table of words.
--- The separator is added between each word.
---
--- @param words string|table string or table of strings
--- @param with_word_cb function (word: string, index: number, words: table) -> string
--- @param separator string|nil (optional)
--- @return string
function TextTransform.transform_words(words, with_word_cb, separator)
  if type(words) ~= "table" then
    words = TextTransform.to_words(words)
  end
  local out = ""
  for i, word in ipairs(words) do
    local new_word = with_word_cb(word, i, word)
    if separator and i > 1 then
      new_word = separator .. new_word
    end
    out = out .. new_word
    D.log("transformers", "word %s (%d) new_word %s out %s", word, i, new_word, out)
  end
  return out
end

--- Transforms a string into camelCase.
--- @param string string
--- @return string
function TextTransform.to_camel_case(string)
  return TextTransform.transform_words(string, function(word, i)
    if i == 1 then
      return word:lower()
    end
    return word:sub(1, 1):upper() .. word:sub(2):lower()
  end)
end

--- Transfroms a string into snake_case.
--- @param string any
--- @return string
function TextTransform.to_snake_case(string)
  return TextTransform.transform_words(string, function(word, i)
    if i == 1 then
      return word:lower()
    end
    return word:lower()
  end, "_")
end

--- Transforms a string into PascalCase.
--- @param string string
--- @return string
function TextTransform.to_pascal_case(string)
  local cc = TextTransform.to_camel_case(string)
  return cc:sub(1, 1):upper() .. cc:sub(2)
end

--- Transforms a string into Title Case.
--- @param string string
--- @return string
function TextTransform.to_title_case(string)
  return TextTransform.transform_words(string, function(word)
    return word:sub(1, 1):upper() .. word:sub(2):lower()
  end, " ")
end

--- Transforms a string into kebab-case.
--- @param string string
--- @return string
function TextTransform.to_kebab_case(string)
  return TextTransform.transform_words(string, function(word)
    return word:lower()
  end, "-")
end

--- Transforms a string into dot.case.
--- @param string string
--- @return string
function TextTransform.to_dot_case(string)
  return TextTransform.transform_words(string, function(word)
    return word:lower()
  end, ".")
end

--- Transforms a string into CONSTANT_CASE.
--- @param string string
--- @return string
function TextTransform.to_const_case(string)
  return TextTransform.transform_words(string, function(word)
    return word:upper()
  end, "_")
end

return TextTransform
