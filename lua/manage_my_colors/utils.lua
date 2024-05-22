---@class Utils
---@field match_flavour fun(tbl: table, cb: fun(flavour: any)): fun(): boolean
---@field match_table fun(cb: fun(flavour: any)): fun(): boolean
---@field default fun(): fun(): boolean
---@field append_flavour_to_name fun(sep: string): fun(): boolean
local utils = {}

local test = {
	-- ["rose-pine"] = function()
	-- 	print("matched rose-pine :)")
	-- end,
	"rose-pine",
	["rose-pine-moon"] = "",
	"rose-pine-cool",
	"stuff",
	"hello",
	"soething",
}

local gruvbox_test = {
	{ "dark", "medium" },
	{ "dark", "hard" },
	{ "light", "soft" },
	{ "dark", "soft" },
	{ "light", "medium" },
	{ "light", "hard" },
}

function utils.match_flavour(tbl, cb)
	local function matcher(_, flavour)
		for k, v in pairs(tbl) do
			if type(v) == "string" and v == flavour then
				if cb then
					cb(v)
					return
				end
				vim.cmd.colorscheme(v)
				return
			elseif type(v) == "table" and v[1] == flavour[1] and v[2] == flavour[2] then
				print("matched")
				if cb then
					cb(v)
				end
			end
			if k == flavour then
				if type(v) == "function" then
					v()
					return
				elseif cb then
					cb(v)
					return
				end
				vim.cmd.colorscheme(k)
				return
			end
		end
	end
	return matcher
end

function utils.match_table(cb)
	local function match_table(_, flavour, flavours)
		for _, v in ipairs(flavours) do
			if type(v) ~= "table" then
				error("use utils.match_flavour or utils.default for strings")
				return false
			end
			if v[1] == flavour[1] and v[2] == flavour[2] then
				if not cb then
					error("no callback found")
				end
				cb(v)
				return true
			end
		end
	end
	return match_table
end

function utils.default()
	local function default(name, flavour)
		local active_themes = require("manage_my_colors.state").active_theme.flavours or {}
		for _, v in pairs(active_themes) do
			if type(v) == "string" and v == flavour then
				vim.cmd.colorscheme(v)
				return true
			end
		end
		error("Error finding flavour.\ndoes " .. name .. "only consist of string?")
	end
	return default
end

function utils.append_flavour_to_name(sep)
	sep = sep or "-"
	local function append(name, flavour)
		local active_themes = require("manage_my_colors.state").active_theme.flavours or {}
		for _, v in pairs(active_themes) do
			if type(v) == "string" and v == flavour then
				vim.cmd.colorscheme(name .. sep .. v)
				return true
			end
		end
	end
	return append
end

return utils
