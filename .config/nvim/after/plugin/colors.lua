function ColorMyPencils(color)
	color = color or "onedark_vivid"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	-- vim.api.nvim_set_hl(0, "LineNr", { guibg = "none"})
end
ColorMyPencils("onedark_vivid")
