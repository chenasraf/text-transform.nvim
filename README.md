<p align="center">
  <h1 align="center">text-transform.nvim</h2>
</p>

<p align="center">
   Common text transformers for nvim - switch between camelCase, PascalCase, snake_case, and more!
</p>

<div align="center">
  
![Demo](https://github.com/chenasraf/text-transform.nvim/assets/167217/20c0106e-2c3b-4dd5-894e-23b313d8bc6b)

</div>

## ⚡️ Features

Transform the current word or selection between multiple case types. Need to easily replace `myVar`
with `my_var` or vice versa? This plugin is for you!

- Works on current word in **Normal Mode**
  - Will replace the current word selectable by <kbd>ciw</kbd>
- Works on selection in **Visual Mode**
  - Will replace only inside the selection
- Works on column selections in **Visual Block Mode**
  - Will detect if the block is a single column or multiple columns
    - If it's a single column, will replace the word under each cursor
    - If it's a selection with length, will replace only inside the selection ranges

| Transformation | Example Inputs              | Output   |
| -------------- | --------------------------- | -------- |
| `camelCase`    | `my_var`, `my-var`, `MyVar` | `myVar`  |
| `PascalCase`   | `my_var`, `my-var`, `myVar` | `MyVar`  |
| `snake_case`   | `myVar`, `my-var`, `MyVar`  | `my_var` |
| `kebab-case`   | `my_var`, `myVar`, `MyVar`  | `my-var` |
| `dot.case`     | `my_var`, `my-var`, `MyVar` | `my.var` |
| `Title Case`   | `my_var`, `my-var`, `MyVar` | `My Var` |
| `CONST_CASE`   | `my_var`, `my-var`, `MyVar` | `MY_VAR` |

## 🔽 Installation

<div>
<table>
<thead>
<tr>
<th>
<img width="221" height="1"/>
Package manager
</th>
<th>
<img width="661" height="1"/>
Snippet
</th>
</tr>
</thead>
<tbody>
<tr>
<td>

[folke/lazy.nvim](https://github.com/folke/lazy.nvim)

</td>
<td>

```lua
-- stable version
require("lazy").setup({
  "chenasraf/text-transform.nvim",
  version = "*", -- or: tag = "stable"
  dependencies = {
    -- for Telescope popup
    'nvim-telescope/telescope.nvim',
    'nvim-lua/plenary.nvim',
  },
})
-- dev version
require("lazy").setup({
  "chenasraf/text-transform.nvim",
  branch = "develop",
  dependencies = {
    -- for Telescope popup
    'nvim-telescope/telescope.nvim',
    'nvim-lua/plenary.nvim',
  },
})
```

</td>
</tr>
<tr>
<td>

[wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim)

</td>
<td>

```lua
-- stable version
use { "chenasraf/text-transform.nvim",
  tag = "stable",
}
-- dev version
use { "chenasraf/text-transform.nvim",
  branch = "develop",
}
```

</td>
</tr>
<tr>
<td>

[junegunn/vim-plug](https://github.com/junegunn/vim-plug)

</td>
<td>

```vim
-- Dependencies - for Telescope popup
Plug "nvim-telescope/telescope.nvim"
Plug "nvim-lua/plenary.nvim"

-- stable version
Plug "chenasraf/text-transform.nvim", {
  "tag": "stable",
}
-- dev version
Plug "chenasraf/text-transform.nvim", {
  "branch": "develop",
}
```

</td>
</tr>

</tbody>
</table>
</div>

## 🚀 Getting started

To get started, [install](#-installation) the plugin via your favorite package manager.

1. Use the following code to setup in any loaded `.lua` file

   ```lua
   require('text-transform').setup({
       -- custom settings
   })
   ```

1. Either make a selection using Visual mode, or just have your cursor stand on a desired word.

   Then, use the mapped key (default: <kbd>&lt;Leader&gt;~</kbd>) to open the transform options in a
   popup.

1. Select the desired transform and you're done!

## ⚙️ Configuration

> **Note**: The options are also available in Neovim by calling `:h TextTransform.options`

The following are the default options when none are configured by the user.

To merge any new config into the default, you can override only the keys you need, and leave the
rest to use the defaults.

```lua
require("text-transform").setup({
  -- Prints information about internals of the plugin. Very verbose, only useful for debugging.
  debug = false,
  -- Keymap configurations
  keymap = {
    -- Keymap to open the telescope popup. Set to `false` or `nil` to disable keymapping
    -- You can always customize your own keymapping manually.
    telescope_popup = {
      -- Opens the popup in normal mode
      ["n"] = "<Leader>~",
      -- Opens the popup in visual/visual block modes
      ["v"] = "<Leader>~",
    },
  },
  ---
  --- Configurations for the text-transform replacers
  --- Keys indicate the replacer name, and the value is a table with the following options:
  ---
  --- - `enabled` (boolean): Enable or disable the replacer - disabled replacers do not show up in the popup.
  replacers = {
    camel_case = { enabled = true },
    const_case = { enabled = true },
    dot_case = { enabled = true },
    kebab_case = { enabled = true },
    pascal_case = { enabled = true },
    snake_case = { enabled = true },
    title_case = { enabled = true },
  },
})
```

## 📝 Commands

The following commands are available for your use in your own mappings or for reference.

| Command                            | Description                                                                                            |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `:TtTelescope` \| `:TextTransform` | Pops up a Telescope window with the available converters which will directly act on the selected text. |
| `:TtCamel`                         | Replaces selection with `camelCase`.                                                                   |
| `:TtConst`                         | Replaces selection with `CONST_CASE`.                                                                  |
| `:TtDot`                           | Replaces selection with `dot.case`.                                                                    |
| `:TtKebab`                         | Replaces selection with `kebab-case`.                                                                  |
| `:TtPascal`                        | Replaces selection with `PascalCase`.                                                                  |
| `:TtSnake`                         | Replaces selection with `snake_case`.                                                                  |
| `:TtTitle`                         | Replaces selection with `Title Case`.                                                                  |

## ⌨️⌨️ Keymaps

You can use the setup options to customize the default keymaps used to trigger the Telescope Popup.

To disable these automated mappings, pass `nil` or `false` to the containing table (e.g.
`telescope_popup`) or to the keys themselves.

```lua
-- Disable entirely
require("text-transform").setup({
  keymap = {
    telescope_popup = nil,
  },
})
-- Disable just one keymap
require("text-transform").setup({
  keymap = {
    telescope_popup = {
      ["v"] = nil,
    },
  },
})
```

You can also create custom mappings to specific case conversions or to the Telescope popup yourself.

```lua
-- Trigger telescope popup
local telescope = require('text-transform.telescope')
vim.keymap.set("n", "<leader>~~", telescope.popup, { silent = true })

-- Trigger case converters directly
vim.keymap.set({ "n", "v" }, "<leader>Ccc", ":TtCamel",  { silent = true })
vim.keymap.set({ "n", "v" }, "<leader>Cco", ":TtConst",  { silent = true })
vim.keymap.set({ "n", "v" }, "<leader>Cdo", ":TtDot",    { silent = true })
vim.keymap.set({ "n", "v" }, "<leader>Cke", ":TtKebab",  { silent = true })
vim.keymap.set({ "n", "v" }, "<leader>Cpa", ":TtPascal", { silent = true })
vim.keymap.set({ "n", "v" }, "<leader>Csn", ":TtSnake",  { silent = true })
vim.keymap.set({ "n", "v" }, "<leader>Ctt", ":TtTitle",  { silent = true })
```

## 💁🏻 Contributing

I am developing this package on my free time, so any support, whether code, issues, or just stars is
very helpful to sustaining its life. If you are feeling incredibly generous and would like to donate
just a small amount to help sustain this project, I would be very very thankful!

<a href='https://ko-fi.com/casraf' target='_blank'>
  <img height='36' style='border:0px;height:36px;'
    src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'
    alt='Buy Me a Coffee at ko-fi.com' />
</a>

I welcome any issues or pull requests on GitHub. If you find a bug, or would like a new feature,
don't hesitate to open an appropriate issue and I will do my best to reply promptly.

If you are a developer and want to contribute code, feel free to fork this repository and make some
changes to create a PR, I will do my best to merge your code if it is appropriate.
