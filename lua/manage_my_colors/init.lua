local config = require("manage_my_colors.config")
local state = require("manage_my_colors.state")

---@class ThemeSwitcher
---@field config Config
---@field persistance? Persistance
---@field get_colorscheme_from_name fun(name: string): Colorscheme|nil
local M = {}

function M.setup(opts)
	config.setup(opts)
	M.config = config.config
	state.init(M.config)
	require("manage_my_colors.commands")
end

function M.get_colorscheme_from_name(name)
	for _, v in ipairs(M.config.colorschemes) do
		if name == v.name then
			return v
		end
	end
end

function M.get_colorschemes()
	return M.config.colorschemes
end

function M.get_persistance_path()
	return M.config.persistance
end

return M
