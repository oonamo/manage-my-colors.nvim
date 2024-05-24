local buf, win
---@class Dimensions
---@field row number
---@field col number
---@field width number
---@field height number

---@class Popup
---@field buf number
---@field win number
---@field dimensions fun(): Dimensions
---@field openwindow fun(themes: any[], callback: fun(idx: number))
---@field callback fun(Colorscheme)
---@field position number
---@field max_len number
---@field get_selection fun(): Colorscheme
local M = {}

function M.dimensions()
	local totalWidth = vim.api.nvim_get_option_value("columns", {})
	local totalHeight = vim.api.nvim_get_option_value("lines", {})
	local height = math.ceil(totalHeight * 0.4 - 4)
	local width = math.ceil(totalWidth * 0.3)

	return {
		row = math.ceil((totalHeight - height) / 2 - 1),
		col = math.ceil((totalWidth - width) / 2),
		height = M.max_len,
		width = width,
	}
end

function M.openwindow(items, callback)
	M.callback = callback
	M.position = 1
	buf = vim.api.nvim_create_buf(false, true)
	M.max_len = #items
	vim.api.nvim_set_option_value("filetype", "mmc", { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })

	local dims = M.dimensions()
	local winopts = {
		style = "minimal",
		relative = "editor",
		border = "double",
		width = dims.width,
		height = dims.height,
		row = dims.row,
		col = dims.col,
		title = "Manage My Colors",
	}
	M.__setMappings()
	win = vim.api.nvim_open_win(buf, true, winopts)
	vim.api.nvim_set_option_value("cursorline", true, { win = win })
	for i, v in ipairs(items) do
		-- TODO: vim.isarray would be better, but idk when it was introduced
		if type(v) == "table" then
			local line = string.format("%s, %s", v[1], v[2])
			vim.api.nvim_buf_set_lines(buf, i - 1, -1, true, { line })
		else
			vim.api.nvim_buf_set_lines(buf, i - 1, -1, true, { v })
		end
	end
end

function M.__setMappings()
	local mappings = {
		k = function()
			M.update_cursor(-1)
		end,
		j = function()
			M.update_cursor(1)
		end,
		["<Esc>"] = function()
			M.close_window()
		end,
		["q"] = function()
			M.close_window()
		end,
		["<cr>"] = function()
			M.callback(M.position)
			M.close_window()
		end,
	}
	for k, v in pairs(mappings) do
		vim.keymap.set("n", k, v, { buffer = buf })
	end
end

function M.update_cursor(direction)
	local position = M.position + direction
	if position < M.max_len and position > 0 then
		M.position = position
	else
		if direction == -1 then
			M.position = 1
			return
		else
			M.position = M.max_len
		end
	end
	vim.api.nvim_win_set_cursor(win, { M.position, 0 })
end

function M.close_window()
	vim.api.nvim_win_close(win, true)
end

return M
