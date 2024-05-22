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
---@field openwindow fun(themes: Colorscheme[], callback: fun(Colorscheme))
---@field callback fun(Colorscheme)
---@field position number
---@field max_len number
---@field selection Colorscheme
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
		height = height,
		width = width,
	}
end

local testThemes = {
	{ name = "modus" },
	{ name = "catpuccin" },
	{ name = "kanagawa" },
	{ name = "doom-one" },
	{ name = "gruvbox" },
	{ name = "rose-pine" },
}

function M.openwindow(themes, callback)
	M.callback = callback
	-- DEBUG
	M.themes = themes
	M.position = 1
	buf = vim.api.nvim_create_buf(false, true)
	M.max_len = #themes
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
	for i, v in ipairs(themes) do
		vim.api.nvim_buf_set_lines(buf, i - 1, -1, true, { v.name })
	end
end

function M.__setMappings()
	local mappings = {
		k = function()
			M.update_cursor(-1)
			-- M.position = M.position - 1 > 0 and M.position - 1 or 1
			vim.notify(string.format("%d", M.position))
			-- vim.api.nvim_win_set_cursor(win, { M.position, 0 })
		end,
		j = function()
			M.update_cursor(1)
			-- M.position = M.position + 1 < M.max_len and M.position + 1 or M.max_len
			vim.notify(string.format("%d", M.position))
			-- vim.api.nvim_win_set_cursor(win, { M.position, 0 })
		end,
		["<Esc>"] = function()
			-- vim.api.nvim_win_close(win, true)
			M.close_window()
		end,
		["q"] = function()
			-- vim.api.nvim_win_close(win, true)
			M.close_window()
		end,
		["<cr>"] = function()
			M.selection = M.themes[M.position]
			M.callback(M.selection)
			-- vim.api.nvim_win_close(win, true)
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

function M.get_selection()
	return M.selection
end

function M.close_window()
	vim.api.nvim_win_close(win, true)
end

-- M.openwindow(testThemes)

return M
