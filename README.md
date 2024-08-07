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

### [Lazy](https://github.com/folke/lazy.nvim)

```lua
require("lazy").setup({
  "chenasraf/text-transform.nvim",
  -- stable version
  version = "*", -- or: tag = "stable"
  -- dev version
  -- branch = "develop",
  -- Optional - for Telescope popup
  dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' }
})
```

### [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use { "chenasraf/text-transform.nvim",
  -- stable version
  tag = "stable",
  -- dev version
  -- branch = "develop",
  -- Optional - for Telescope popup
  requires = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' }
}
```

### [Plug](https://github.com/junegunn/vim-plug)

```vim
" Dependencies - optional for Telescope popup
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/plenary.nvim'

" stable version
Plug 'chenasraf/text-transform.nvim', { 'tag': 'stable' }
" dev version
Plug 'chenasraf/text-transform.nvim', { 'branch': 'develop' }
```

If you decide not to use Telescope, you can ignore the dependencies. In that case, be sure to change
your config with `popup_type = 'select'` so that TextTransform never tries to load Telescope.

It falls back to `vim.ui.select()` instead, which may or may not still be Telescope behind the
scenes, or something else; depending on your setup.

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
  --- Prints information about internals of the plugin. Very verbose, only useful for debugging.
  debug = false,
  --- Keymap configurations
  keymap = {
    --- Keymap to open the telescope popup. Set to `false` or `nil` to disable keymapping
    --- You can always customize your own keymapping manually.
    telescope_popup = {
      --- Opens the popup in normal mode
      ["n"] = "<Leader>~",
      --- Opens the popup in visual/visual block modes
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

  --- Sort the replacers in the popup.
  --- Possible values: 'frequency', 'name'
  sort_by = "frequency",

  --- The popup type to show.
  --- Possible values: 'telescope', 'select'
  popup_type = 'telescope'
})
```

## 📝 Commands

The following commands are available for your use in your own mappings or for reference.

| Command          | Description                                                                                                            |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `:TextTransform` | Pop up a either a Telescope window or a selection popup, depending on the `popup_type` config.                         |
| `:TtTelescope`   | Pop up a Telescope window with all the transformers, which will directly act on the selected text or highlighted word. |
| `:TtSelect`      | Pop up a selection popup with all the transformers, which will directly act on the selected text or highlighted word.  |
| `:TtCamel`       | Replace selection/word with `camelCase`.                                                                               |
| `:TtSnake`       | Replace selection/word with `snake_case`.                                                                              |
| `:TtPascal`      | Replace selection/word with `PascalCase`.                                                                              |
| `:TtConst`       | Replace selection/word with `CONST_CASE`.                                                                              |
| `:TtDot`         | Replace selection/word with `dot.case`.                                                                                |
| `:TtKebab`       | Replace selection/word with `kebab-case`.                                                                              |
| `:TtTitle`       | Replace selection/word with `Title Case`.                                                                              |

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
vim.keymap.set("n", "<leader>~~", ":TtTelescope", { silent = true, desc = "Transform Text" })

-- Trigger case converters directly
vim.keymap.set({ "n", "v" }, "<leader>Ccc", ":TtCamel",  { silent = true, desc = "To camelCase" })
vim.keymap.set({ "n", "v" }, "<leader>Csn", ":TtSnake",  { silent = true, desc = "To snake_case" })
vim.keymap.set({ "n", "v" }, "<leader>Cpa", ":TtPascal", { silent = true, desc = "To PascalCase" })
vim.keymap.set({ "n", "v" }, "<leader>Cco", ":TtConst",  { silent = true, desc = "To CONST_CASE" })
vim.keymap.set({ "n", "v" }, "<leader>Cdo", ":TtDot",    { silent = true, desc = "To dot.case" })
vim.keymap.set({ "n", "v" }, "<leader>Cke", ":TtKebab",  { silent = true, desc = "To kebab-case" })
vim.keymap.set({ "n", "v" }, "<leader>Ctt", ":TtTitle",  { silent = true, desc = "To Title Case" })
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
