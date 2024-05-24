# Manage My Colors
## Overview
- Complete customization of your themes
- Persistance across sessions
- Integrate with other tools
## Install
[lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{ 
    "oonamo/manage-my-colors.nvim", 
    priority = 1000,
    opts = {} -- Your configuration options here
}
```

[packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use({ "oonamo/manage-my-colors.nvim" })
```

[vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'oonamo/manage-my-colors.nvim'
```
## Usage
### Basic Configuration
When no action function is specified, Manage My Colors defaults to calling `vim.cmd.colorscheme(color_scheme)`
```lua
local utils = require("manage_my_colors.utils")
require("manage-my-colors").setup({
    -- can also be a path to a file
    persistance = true, -- gets replaced with a path that is used to save to state
    after_all = function(theme, flavour) end, -- gets called after every succesfull change in color or flavour
    default_theme = {     -- Called when an appropiate colorscheme is not found
        name = "default", -- Can be any colorscheme
    },
    colorschemes = {
        {
            name = "rose-pine", 

            -- See utils to see how to implement flavours
            flavours = { "rose-pine-main", "rose-pine-moon", "rose-pine-dawn" },
            action = utils.default()
        },
        { 
            name = "habamax"
        },
    }
})

vim.keymap.set("n", "<leader>cp", "<CMD>ManageMyColors<CR>", { desc = "Toggle Colortheme Popup" })
vim.keymap.set("n", "<leader>cf", "<CMD>ManageMyFlavour<CR>", { desc = "Toggle next flavour" })
```
### Commands
| Command                        | Description                                                                                                                                                                                                                                                   |
|--------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `:ManageMyColors Theme?` | If called with no arguments, it will create a popup with all your colorschemes. Press `<CR>` to select, and it will call your colorscheme with the first flavour. If the `THEME` argument is provided, it wall call the first flavour of your selected theme. |
| `:ManageMyFlavour Flavour?`             | If called with no arguments, it will create a popup with all your flavours for the current colorscheme. Press <CR> to select, and it will the flavour with your action
## Utils
See their implementation at utils.lua
<details open>
<summary> Utility Definitions</summary>

### `utils.default()`
**Type**: func()

**Returns**: func(name: string, flavour: string|string[], flavours)

**Desc**: Calls `vim.cmd.colorscheme` for the given flavour. Only use if you define flavours as the command needed to use the colorscheme.
#### Example Usage
```lua
{
    name = "rose-pine",
    flavours = { "rose-pine", "rose-pine-moon", "rose-pine-dawn" },
    action = utils.default(),
}
```
### `utils.match_flavour`
**Type**: func(matcher: table, callback: fun(name: string, flavour: string|string[], flavours)

**Returns**: func(name: string, flavour: string|string[], flavours)

**Desc**: Matches the flavour to the key. If it is found in the table, the callback function is called with the following parameters. If it does not find the flavour in the table, it defaults to the callback with the same parameters.
#### Example Usage
```lua
{
    name = "nightfox",
    flavours = { "nightfox", "terafox", "dayfox", "dawnfox" },
    action = utils.match_flavour({
        ["dayfox"] = function(name, flavour, flavours)
            vim.o.background = "light"
            vim.cmd.colorscheme(flavour)
        end,
        ["dawnfox"] = function(name, flavour, flavours)
            vim.o.background = "light"
            vim.o.cursorline = true
            vim.cmd.colorscheme(flavour)
        end,
    }, function(name, flavour, flavours)
            vim.o.background = "dark"
            vim.cmd.colorscheme(flavour)
        end)
}
```
### `utils.match_table`
**Type**: fun(cb: fun(name, flavour, flavours))

**Returns**: func(name: string, flavour: string|string[], flavours)

**Desc**: Matches a 2 element flavour array, and returns it as the flavour parameter.

#### Example Usage
```lua
{
    name = "gruvbox-material",
    flavours = {
        { "dark", "soft" },
        { "dark", "medium" },
        { "dark", "hard" },
        { "light", "soft" },
        { "light", "medium" },
        { "light", "hard" },
    },
    action = utils.match_table(function(name, flavour, flavours)
        vim.o.background = flavour[1]
        vim.g.gruvbox_material_background = flavour[2]
        vim.cmd.colorscheme("gruvbox-material")
    end),
},
```

### `utils.append_flavour_to_name`
**Type**: fun(seperator: string|"-")

**Returns**: func(name: string, flavour: string|string[], flavours)

**Desc**: Appends the flavour to the name. In this example, if the current flavour is `wave`, the flavour parameter becomes `kanagawa-wave`. It then calls `vim.cmd.colorscheme` with the new flavour parameter.

#### Example Usage
```lua
{
    name = "kanagawa",
    flavours = { "wave", "dragon", "lotus" },
    action = utils.append_flavour_to_name("-"),
},
```
</details>

### Type Definitions
<details>
<summary> Type Definitions</summary>

```lua 
---@alias cb fun(name: string, flavour: any, flavours: any[])
---@alias action cb: boolean

---@class Utils
---@field match_flavour fun(tbl: table, cb: cb): action
---@field match_table fun(cb: cb): action
---@field default fun(): fun(): boolean
---@field append_flavour_to_name fun(sep: string): fun(): boolean

---@class Colorscheme
---@field name string
---@field flavours? table
---@field action? function

---@class Config
---@field persistance boolean|string
---@field default_theme Colorscheme
---@field colorschemes Colorscheme[]
---@field after_all fun(active_theme: Colorscheme, active_flavour: any)
---@field before_all fun(active_theme: Colorscheme, active_flavour: any)

---@alias flavour string

---@class State
---@field colorscheme string
---@field flavour string|string[]|nil
---@field current_idx number
---@field active_theme Colorscheme
---@field do_colorscheme fun()
---@field init fun(opts: Config)
---@field get_theme fun(): Colorscheme
---@field update_theme fun(new_theme: Colorscheme)
---@field next_flavour fun()
---@field after fun(active_theme: Colorscheme, active_flavour: any)
---@field before fun(active_theme: Colorscheme, active_flavour: any)
---@field get_flavour_index_from_name fun(name: string): number
---@field change_flavour_by_name fun(name: string)
---@field change_flavour_by_index fun(idx: number)

---@class Persistance
---@field __load fun(opts: Config): State, string|nil
---@field __save fun(theme: Colorscheme, idx: number)
---@field __init fun(opts: Config): State|nil
---@field persistance_path string
---@field name string|string[]
---@field current_idx number
---@field state State

-- Access this class with
-- require("manage_my_colors")
---@class ThemeSwitcher
---@field config Config
---@field persistance? Persistance
---@field get_colorscheme_from_name fun(name: string): Colorscheme|nil
---@field get_colorschemes fun(): Colorscheme[]
---@field get_persistance_path fun(): string
```
---
</details>

## Integrations
### Wezterm
> [!NOTE]  
> This is untested as of now 
```lua
require("manage_my_colors").setup({
    -- calls this function after every change in flavour or colorscheme
    after_all = function(active_theme, active_flavour)
         -- Open some file to store the data
	local file_path = vim.fn.expand("~") .. "/.config/wezterm/colorscheme"
         -- Normalize path
	file_path = file_path:gsub("\\", "/")
	local file = io.open(file_path, "w")
         local colorscheme = active_theme.name
	if file then
		if type(active_flavour) == "table" then
                    for _, v in ipairs(active_flavour) do
                        if v ~= "" or v ~= " " then
                            colorscheme = colorscheme .. "|" .. v
                        end
                    end
		elseif active_flavour ~= "" then
                        colorscheme = colorscheme .. "|" .. active_flavour
		end
		if colorscheme:sub(-1) == "|" then
			colorscheme = colorscheme:sub(1, -2)
		end
		file:write(colorscheme)
		file:close()
	end
	vim.notify("Saved Wezterm color scheme to: " .. file_path, vim.log.levels.INFO)
    end,
})
```
