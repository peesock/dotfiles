function ColorMyPencils(color)
	color = color or "onedark"
	vim.cmd.colorscheme(color)

	-- some colorizor mods
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	vim.api.nvim_set_hl(0, "FloatBorder", { fg = "white" })
	vim.api.nvim_set_hl(0, "DiagnosticInfo", { sp = "none" })
	-- #123456

	-- remove text highlighting but not underlighting of diagnostics
	for _, value in pairs({"Ok", "Hint", "Info", "Warn", "Error",}) do
		vim.api.nvim_set_hl(0, "DiagnosticUnderline" .. value, {
			sp = vim.api.nvim_get_hl(0, { name = "DiagnosticUnderline" .. value }).fg,
			underline = true,
			-- undercurl = true,
			-- underdouble = true;
			-- underdashed = true,
			-- underdotted = true,
		})
	end
	-- vim.api.nvim_set_hl(0, "LineNr", { bg = "none"})
end
ColorMyPencils() -- initialize with my most beloved theme
