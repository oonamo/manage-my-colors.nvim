---@class Persistance
---@field __load fun(opts: Config): State, string|nil
---@field __save fun(theme: Colorscheme, idx: number)
---@field __init fun(opts: Config): State|nil
---@field persistance_path string
---@field name string|string[]
---@field current_idx number
---@field state State
local M = {}

function M.__load(opts)
	---@diagnostic disable-next-line: param-type-mismatch
	local file = io.open(opts.persistance)
	---@diagnostic disable-next-line: assign-type-mismatch
	M.persistance_path = opts.persistance
	if file then
		local contents = file:read()
		local split = vim.split(contents, ",")
		local colorscheme, capture = split[1], split[2]
		local flavours = vim.split(capture, "|")
		if flavours and #flavours == 1 then
			---@diagnostic disable-next-line: cast-local-type
			flavours = flavours[1]
		end
		file:close()
		return { colorscheme = colorscheme, flavour = flavours }
	end
	return {}, "Could not load file"
end

function M.__save(state, idx)
	local state_string = state.name .. ","
	if not state.flavours then
		vim.fn.writefile({ state_string }, M.persistance_path)
		return
	end
	if type(state.flavours[idx]) == "string" then
		state_string = state_string .. state.flavours[idx]
	elseif type(state.flavours[idx]) == "table" then
		---@diagnostic disable-next-line: param-type-mismatch
		for _, v in ipairs(state.flavours[idx]) do
			if v ~= "" or v ~= " " then
				state_string = state_string .. v .. "|"
			end
		end
		state_string = state_string:gsub(-1, 2)
	end
	vim.fn.writefile({ state_string }, M.persistance_path)
end

return M
