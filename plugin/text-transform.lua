-- You can use this loaded variable to enable conditional parts of your plugin.
if _G.TextTransformLoaded then
    return
end

_G.TextTransformLoaded = true

local function into_words(str)
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

function IntoWords(string)
    print(vim.inspect(into_words(string)))
end

function CamelCase(string)
    local words = into_words(string)
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

function SnakeCase(string)
    local words = into_words(string)
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

function PascalCase(string)
    local words = into_words(string)
    local pascal_case = ""
    for _, word in ipairs(words) do
        pascal_case = pascal_case .. word:sub(1, 1):upper() .. word:sub(2):lower()
    end
    return pascal_case
end

function KebabCase(string)
    local words = into_words(string)
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

function DotCase(string)
    local words = into_words(string)
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

function TitleCase(string)
    local words = into_words(string)
    local title_case = ""
    for i, word in ipairs(words) do
        title_case = title_case .. word:sub(1, 1):upper() .. word:sub(2):lower()
        if i ~= #words then
            title_case = title_case .. " "
        end
    end
    return title_case
end

function ReplaceCurrentSelection(transform)
    local selection = vim.fn.getline("'<", "'>")
    local transformed = transform(selection)
    vim.fn.setline("'<", transformed)
end

function ReplaceCurrentWord(transform)
    local word = vim.fn.expand("<cword>")
    local transformed = transform(word)
    vim.cmd("normal ciw" .. transformed)
end

local should_test = false

if should_test then
    local map = {
        ["CamelCase"] = CamelCase,
        ["SnakeCase"] = SnakeCase,
        ["PascalCase"] = PascalCase,
        ["KebabCase"] = KebabCase,
        ["DotCase"] = DotCase,
        ["TitleCase"] = TitleCase,
    }

    for k, tst in pairs(map) do
        print(k .. ": " .. "hello_world" .. " => " .. tst("hello_world"))
        print(k .. ": " .. "HELLO_WORLD" .. " => " .. tst("HELLO_WORLD"))
        print(k .. ": " .. "HelloWorld" .. " => " .. tst("HelloWorld"))
        print(k .. ": " .. "Hello-World" .. " => " .. tst("Hello-World"))
    end
end
-- use input from current word in editor
vim.cmd("amenu Transforms.&camelCase :lua ReplaceCurrentWord(CamelCase)<CR>")
vim.cmd("amenu Transforms.&snake_case :lua ReplaceCurrentWord(SnakeCase)<CR>")
vim.cmd("amenu Transforms.&PascalCase :lua ReplaceCurrentWord(PascalCase)<CR>")
vim.cmd("amenu Transforms.&kebab-case :lua ReplaceCurrentWord(KebabCase)<CR>")
vim.cmd("amenu Transforms.&dot\\.case :lua ReplaceCurrentWord(DotCase)<CR>")
vim.cmd("amenu Transforms.&Title\\ Case :lua ReplaceCurrentWord(TitleCase)<CR>")

for kmap in _G.TextTransform.config.keymap do
    vim.keymap.set({ "n", "v" }, kmap, "<cmd>popup Transforms<CR>", { silent = true })
end
