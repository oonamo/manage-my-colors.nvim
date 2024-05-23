local commander = vim.api.nvim_create_user_command
local colorschemes = require("manage_my_colors").get_colorschemes()
local color_scheme_tbl = {}
for _, v in ipairs(colorschemes) do
	table.insert(color_scheme_tbl, v.name)
end

commander("ManageMyFlavour", function()
	require("manage_my_colors.state").next_flavour()
end, { nargs = 0 })

commander("ManageMyColors", function(opts)
	local state = require("manage_my_colors.state")
	if opts.fargs[1] then
		state.update_theme(require("manage_my_colors").get_colorscheme_from_name(opts.fargs[1]))
		return
	end
	local popup = require("manage_my_colors.popup")
	popup.openwindow(colorschemes, function(selection)
		if selection then
			vim.notify("selected " .. selection.name)
			state.update_theme(selection)
			return
		end
	end)
end, {
	nargs = "?",
	complete = function()
		return color_scheme_tbl
	end,
})
