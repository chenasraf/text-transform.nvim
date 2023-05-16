-- You can use this loaded variable to enable conditional parts of your plugin.
if _G.TextTransformLoaded then
  return
end

_G.TextTransformLoaded = true

function TextTransform.into_words(str)
  local words = {}
  local word = ""

  local previous_is_upper = false
  for i = 1, #str do
    local char = str:sub(i, i)
    -- split on uppercase letters
    if char:match("%u") and not previous_is_upper then
      if word ~= "" then
        table.insert(words, word)
      end
      previous_is_upper = true
      word = char
      -- split on underscores, hyphens, and spaces
    elseif char:match("[%_%-%s]") then
      if word ~= "" then
        table.insert(words, word)
        previous_is_upper = false
      end
      word = ""
    else
      word = word .. char
      previous_is_upper = char:match("%u")
    end
  end
  if word ~= "" then
    table.insert(words, word)
    previous_is_upper = false
  end
  return words
end

function TextTransform.camel_case(string)
  local words = TextTransform.into_words(string)
  local camel_case = ""
  for i, word in ipairs(words) do
    if i == 1 then
      camel_case = camel_case .. word:lower()
    else
      camel_case = camel_case .. word:sub(1, 1):upper() .. word:sub(2):lower()
    end
  end
  return camel_case
end

function TextTransform.snake_case(string)
  local words = TextTransform.into_words(string)
  local snake_case = ""
  for i, word in ipairs(words) do
    if i == 1 then
      snake_case = snake_case .. word:lower()
    else
      snake_case = snake_case .. "_" .. word:lower()
    end
  end
  return snake_case
end

function TextTransform.pascal_case(string)
  local words = TextTransform.into_words(string)
  local pascal_case = ""
  for _, word in ipairs(words) do
    pascal_case = pascal_case .. word:sub(1, 1):upper() .. word:sub(2):lower()
  end
  return pascal_case
end

function TextTransform.kebab_case(string)
  local words = TextTransform.into_words(string)
  local kebab_case = ""
  for i, word in ipairs(words) do
    if i == 1 then
      kebab_case = kebab_case .. word:lower()
    else
      kebab_case = kebab_case .. "-" .. word:lower()
    end
  end
  return kebab_case
end

function TextTransform.dot_case(string)
  local words = TextTransform.into_words(string)
  local dot_case = ""
  for i, word in ipairs(words) do
    if i == 1 then
      dot_case = dot_case .. word:lower()
    else
      dot_case = dot_case .. "." .. word:lower()
    end
  end
  return dot_case
end

function TextTransform.title_case(string)
  local words = TextTransform.into_words(string)
  local title_case = ""
  for i, word in ipairs(words) do
    title_case = title_case .. word:sub(1, 1):upper() .. word:sub(2):lower()
    if i ~= #words then
      title_case = title_case .. " "
    end
  end
  return title_case
end

function TextTransform.const_case(string)
  local words = TextTransform.into_words(string)
  local const_case = ""
  for i, word in ipairs(words) do
    if i == 1 then
      const_case = const_case .. word:upper()
    else
      const_case = const_case .. "_" .. word:upper()
    end
  end
  return const_case
end

function TextTransform.replace_selection(transform)
  -- get the current visual selection, and transform the line, only replacing the selected text itself
  local _, start_line, start_col = unpack(vim.fn.getpos("'<"))
  local _, end_line, end_col = unpack(vim.fn.getpos("'>"))
  -- print(vim.inspect(vim.fn.getpos("'<")), vim.inspect(vim.fn.getpos("'>")),
  -- start_line, start_col, end_line, end_col)
  local lines = vim.fn.getline(start_line, end_line)
  -- print(vim.inspect(lines))

  -- transform all included lines
  local transformed = ""

  if #lines == 1 then
    transformed = lines[1]:sub(1, start_col - 1)
      .. transform(lines[1]:sub(start_col, end_col))
      .. lines[1]:sub(end_col + 1)
  else
    transformed = lines[1]:sub(1, start_col - 1) .. transform(lines[1]:sub(start_col)) .. "\n"
    for i = 2, #lines - 1 do
      transformed = transformed .. transform(lines[i]) .. "\n"
    end
    transformed = transformed
      .. transform(lines[#lines]:sub(1, end_col))
      .. lines[#lines]:sub(end_col + 1)
  end

  -- replace the lines with the transformed lines
  vim.fn.setline(start_line, transformed)
  for i = start_line + 1, end_line do
    vim.fn.setline(i, "")
  end

  -- move the cursor to the end of the transformed text
  vim.fn.cursor(end_line, end_col)
end

function TextTransform.replace_word(transform)
  local word = vim.fn.expand("<cword>")
  local transformed = transform(word)
  vim.cmd("normal ciw" .. transformed)
end

local should_test = false

if should_test then
  local map = {
    ["CamelCase"] = TextTransform.camel_case,
    ["SnakeCase"] = TextTransform.snake_case,
    ["PascalCase"] = TextTransform.pascal_case,
    ["KebabCase"] = TextTransform.kebab_case,
    ["DotCase"] = TextTransform.dot_case,
    ["TitleCase"] = TextTransform.title_case,
    ["ConstCase"] = TextTransform.title_case,
  }

  for k, tst in pairs(map) do
    print(k .. ": " .. "hello_world" .. " => " .. tst("hello_world"))
    print(k .. ": " .. "HELLO_WORLD" .. " => " .. tst("HELLO_WORLD"))
    print(k .. ": " .. "HelloWorld" .. " => " .. tst("HelloWorld"))
    print(k .. ": " .. "Hello-World" .. " => " .. tst("Hello-World"))
  end
end
