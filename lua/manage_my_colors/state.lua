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
local M = {}

local persistance = require("manage_my_colors.persistance")

function M.do_colorscheme()
	local theme = M.active_theme
	local flavour = theme.flavours and theme.flavours[M.current_idx] or nil
	M.before(theme, flavour)
	if type(theme.action) == "function" then
		local found = theme.action(theme.name, flavour, theme.flavours)
		if not found then
			return
		end
	else
		vim.cmd.colorscheme(theme.name)
	end
	M.after(theme, flavour)
end

function M.init(opts)
	M.after = opts.after_all
	M.before = opts.before_all
	M.current_idx = 1
	if not opts.persistance then
		vim.notify("persistance is not setup", vim.logs.levels.ERROR)
		return
	end
	local state, err = persistance.__load(opts)
	if err then
		M.active_theme = opts.default_theme
		if not M.active_theme.flavours then
			-- goto color
			M.do_colorscheme()
			return
		end
		M.flavour = M.active_theme.flavours[M.current_idx]
		M.do_colorscheme()
		return
	end
	for _, v in pairs(opts.colorschemes) do
		if v.name == state.colorscheme then
			M.active_theme = v
			break
		end
	end
	if not M.active_theme then
		vim.notify("did not find " .. state.colorscheme, vim.log.levels.WARN)
		M.active_theme = opts.default_theme
		goto color
	end
	if state.flavour == nil then
		state.flavour = ""
	elseif M.active_theme.flavours then
		for i, v in ipairs(M.active_theme.flavours) do
			if type(v) == "table" then
				if v[1] == state.flavour[1] and v[2] == state.flavour[2] then
					M.current_idx = i
					break
				end
			elseif v == state.flavour then
				M.current_idx = i
				break
			end
		end
		goto color
	end
	::color::
	M.do_colorscheme()
end

function M.get_theme()
	return M.active_theme
end

function M.update_theme(new_theme)
	if not new_theme then
		return
	end
	M.active_theme = new_theme
	M.current_idx = 1
	M.do_colorscheme()
	persistance.__save(M.active_theme, M.current_idx)
end

function M.next_flavour()
	if #M.active_theme.flavours == 1 or M.active_theme.flavours == nil then
		vim.notify("no other flavour for this colorscheme", vim.log.levels.INFO)
		return
	end
	M.current_idx = M.current_idx == #M.active_theme.flavours and 1 or M.current_idx + 1
	M.do_colorscheme()
	persistance.__save(M.active_theme, M.current_idx)
end

function M.change_flavour_by_name(flavour)
	local idx = M.get_flavour_index_from_name(flavour)
	M.current_idx = idx
	M.do_colorscheme()
	persistance.__save(M.active_theme, M.current_idx)
end

function M.change_flavour_by_index(idx)
	M.current_idx = idx
	M.do_colorscheme()
	persistance.__save(M.active_theme, M.current_idx)
end

function M.get_flavour_index_from_name(flavour)
	for i, v in ipairs(M.active_theme) do
		if type(v) == "string" and v == flavour then
			return i
		elseif v[1] == flavour[1] and v[2] == flavour[2] then
			return i
		end
	end
	return -1
end

return M
