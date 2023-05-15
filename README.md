<p align="center">
  <h1 align="center">text-transform.nvim</h2>
</p>

<p align="center">
    > A catch phrase that describes your plugin.
</p>

<div align="center">
    ![Demonstration](https://github.com/chenasraf/text-transform.nvim/assets/167217/e73f0e27-d72d-4aa6-bfa7-6f691aba9713)
</div>

## ⚡️ Features

> Transform the current word or selection between multiple case types. Need to easily replace myVar with my_var or vice versa? This plugin is for you!

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

> Describe how to use the plugin the simplest way

## ⚙ Configuration

> The configuration list sometimes become cumbersome, making it folded by default reduce the noise of the README file.

<details>
<summary>Click to unfold the full list of options with their default values</summary>

> **Note**: The options are also available in Neovim by calling `:h text-transform.options`

```lua
require("text-transform").setup({
    -- you can copy the full list from lua/text-transform/config.lua
})
```

</details>

## 🧰 Commands

|   Command   |         Description        |
|-------------|----------------------------|
|  `:Toggle`  |     Enables the plugin.    |

## ⌨ Contributing

PRs and issues are always welcome. Make sure to provide as much context as possible when opening one.

## 🗞 Wiki

You can find guides and showcase of the plugin on [the Wiki](https://github.com/chenasraf/text-transform.nvim/wiki)

## 🎭 Motivations

> If alternatives of your plugin exist, you can provide some pros/cons of using yours over the others.
