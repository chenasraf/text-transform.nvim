<p align="center">
  <h1 align="center">text-transform.nvim</h2>
</p>

<p align="center">
   Common text transformers for nvim - switch between camelCase, PascalCase, snake_case, and more!
</p>

<div align="center">
  
![Demonstration](https://github.com/chenasraf/text-transform.nvim/assets/167217/e73f0e27-d72d-4aa6-bfa7-6f691aba9713)
  
</div>

## ⚡️ Features

> Transform the current word or selection between multiple case types. Need to easily replace myVar
> with my_var or vice versa? This plugin is for you!

| Transformation | Example Inputs              | Output   |
| -------------- | --------------------------- | -------- |
| `camelCase`    | `my_var`, `my-var`, `MyVar` | `myVar`  |
| `PascalCase`   | `my_var`, `my-var`, `myVar` | `MyVar`  |
| `snake_case`   | `myVar`, `my-var`, `MyVar`  | `my_var` |
| `kebab-case`   | `my_var`, `myVar`, `MyVar`  | `my-var` |
| `dot.case`     | `my_var`, `my-var`, `MyVar` | `my.var` |
| `Title Case`   | `my_var`, `my-var`, `MyVar` | `My Var` |

## 📋 Installation

<div align="center">
<table>
<thead>
<tr>
<th>Package manager</th>
<th>Snippet</th>
</tr>
</thead>
<tbody>
<tr>
<td>

[wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim)

</td>
<td>

```lua
-- stable version
use { "chenasraf/text-transform.nvim", tag = "*" }
-- dev version
use { "chenasraf/text-transform.nvim" }
```

</td>
</tr>
<tr>
<td>

[junegunn/vim-plug](https://github.com/junegunn/vim-plug)

</td>
<td>

```lua
-- stable version
Plug "chenasraf/text-transform.nvim", { "tag": "*" }
-- dev version
Plug "chenasraf/text-transform.nvim"
```

</td>
</tr>
<tr>
<td>

[folke/lazy.nvim](https://github.com/folke/lazy.nvim)

</td>
<td>

```lua
-- stable version
require("lazy").setup({{ "chenasraf/text-transform.nvim", version = "*" }})
-- dev version
require("lazy").setup({ "chenasraf/text-transform.nvim" })
```

</td>
</tr>
</tbody>
</table>
</div>

## ☄ Getting started

To get started, [install](#-installation) the plugin via your favorite package manager.

1. Use the following code to setup in any loaded `.lua` file

   ```lua
   require('text-transform').setup({
       -- custom settings
   })
   ```

1. Either make a selection using Visual mode, or just have your cursor stand on a desired word.

   Then, use the mapped key (default: <kbd><Leader>~</kbd>) to open the transform options in a
   popup.

1. Select the desired transform and you're done!

## ⚙ Configuration

<details>
<summary>Click to unfold the full list of options with their default values</summary>

> **Note**: The options are also available in Neovim by calling `:h text-transform.options`

```lua
require("text-transform").setup({
  -- Prints useful logs about what event are triggered, and reasons actions are executed.
  debug = false,
  -- Keymap to trigger the transform.
  keymap = {
    -- Normal mode keymap.
    ["n"] = "<Leader>~",
    -- Visual mode keymap.
    ["v"] = "<Leader>~",
  },
})
```

</details>

## 🧰 Commands

Use the following as example, you can mix &amp; match the different replacement functions with the
desired transform function.

Normally you wouldn't need to call this, as you would just use the keymap you used in `setup()`.

| Command                                                          | Description                                        |
| ---------------------------------------------------------------- | -------------------------------------------------- |
| `:lua TextTransform.replace_word(TextTransform.camel_case)`      | Replaces selected word with camelCase version.     |
| `:lua TextTransform.replace_selection(TextTransform.snake_case)` | Replaces visual selection with snake_case version. |

## ⌨ Contributing

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
