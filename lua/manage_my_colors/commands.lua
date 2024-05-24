local mmc = require("manage_my_colors")
local state = require("manage_my_colors.state")
local commander = vim.api.nvim_create_user_command
local colorschemes = mmc.get_colorschemes()
local color_scheme_tbl = {}
local flavour_cache = state.get_theme().flavours
for _, v in ipairs(colorschemes) do
	table.insert(color_scheme_tbl, v.name)
end

commander("ManageMyFlavour", function()
	-- require("manage_my_colors.state").next_flavour()
	local popup = require("manage_my_colors.popup")
	if not flavour_cache then
		flavour_cache = state.get_theme().flavours
		if not flavour_cache then
			vim.notify("current colorscheme has no flavours setup")
			return
		end
	end
	popup.openwindow(flavour_cache, function(idx)
		state.change_flavour_by_index(idx)
	end)
end, {
	nargs = "?",
	complete = function()
		return flavour_cache
	end,
})

commander("ManageMyColors", function(opts)
	if opts.fargs[1] then
		state.update_theme(require("manage_my_colors").get_colorscheme_from_name(opts.fargs[1]))
		flavour_cache = state.get_theme().flavours
		return
	end
	local popup = require("manage_my_colors.popup")
	popup.openwindow(color_scheme_tbl, function(idx)
		if idx then
			state.update_theme(colorschemes[idx])
			flavour_cache = state.get_theme().flavours
			return
		end
	end)
end, {
	nargs = "?",
	complete = function()
		return color_scheme_tbl
	end,
})
