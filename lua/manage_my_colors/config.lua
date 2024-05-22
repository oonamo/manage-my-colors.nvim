local M = {}
---@class Colorscheme
---@field name string
---@field flavours? table
---@field action? function

---@class Config
---@field persistance boolean|string
---@field default_theme Colorscheme
---@field colorschemes Colorscheme[]
---@field after_all fun(active_theme: Colorscheme, active_flavour: any)

---@type Config
local defaults = {
	default_theme = { name = "default" },
	persistance = true,
	colorschemes = { { name = "habamax" }, { name = "desert" } },
	after_all = function() end,
}

---@type Config
M.config = defaults

function M.setup(opts)
	opts = opts or {}
	if type(opts.persistance) == "string" then
		defaults.persistance = opts.persistance
	else
		opts.persistance = vim.fn.stdpath("data") .. "/manage_my_colors"
	end
	M.config = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

return M
