---@alias cb fun(name: string, flavour: any, flavours: any[])
---@alias action cb: boolean

---@class Utils
---@field match_flavour fun(tbl: table, cb: cb): action
---@field match_table fun(cb: cb): action
---@field default fun(): fun(): boolean
---@field append_flavour_to_name fun(sep: string): fun(): boolean
local utils = {}

function utils.match_flavour(tbl, cb)
	local function matcher(name, flavour, flavours)
		for k, func in pairs(tbl) do
			if k == flavour then
				if type(func) == "function" then
					func(name, flavour, flavours)
				else
					cb(name, flavour, flavours)
				end
				return true
			end
		end
		cb(name, flavour, flavours)
		return true
	end
	return matcher
end

function utils.match_table(cb)
	local function match_table(name, flavour, flavours)
		for _, v in ipairs(flavours) do
			if type(v) ~= "table" then
				error("use utils.match_flavour or utils.default for strings")
				return false
			end
			if v[1] == flavour[1] and v[2] == flavour[2] then
				if not cb then
					error("no callback found")
				end
				cb(name, flavour, flavours)
				return true
			end
		end
	end
	return match_table
end

function utils.default()
	local function default(name, flavour, flavours)
		for _, v in pairs(flavours) do
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
	local function append(name, flavour, flavours)
		if flavour == "" or not flavour then
			vim.cmd.colorscheme(name)
			return true
		end
		for _, v in pairs(flavours) do
			if type(v) == "string" and v == flavour then
				vim.cmd.colorscheme(name .. sep .. v)
				return true
			elseif type(v) == "table" and v[1] == flavour[1] and v[2] == flavour[2] then
				vim.cmd.colorscheme(name .. sep .. v[1] .. sep .. v[2])
				return true
			end
		end
	end
	return append
end

return utils
