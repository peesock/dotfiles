return {
	{
		"nvim-telescope/telescope.nvim",
		-- enabled = false
		dependencies = {
			'nvim-lua/plenary.nvim',
			{
				'nvim-telescope/telescope-fzy-native.nvim',
				build = 'make',
				cond = function()
					return vim.fn.executable 'make' == 1
				end,
			}
		},
		config = function()
			local telescope = require('telescope')
			local builtin = require('telescope.builtin')
			vim.keymap.set('n', '<leader>tf', builtin.find_files)
			vim.keymap.set('n', '<leader>th', builtin.help_tags)
			vim.keymap.set('n', '<leader>tg', function()
				builtin.grep_string({ search = vim.fn.input("Grep > ") })
			end)
			telescope.setup()
			pcall(require('telescope').load_extension, 'fzy_native')
		end,
	},

	{
		"ThePrimeagen/harpoon",
	},
}
