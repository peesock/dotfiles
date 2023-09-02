return {
	{
		"nvim-telescope/telescope.nvim",
		-- enabled = false
		dependencies = 'nvim-lua/plenary.nvim',
		config = function()
			local builtin = require('telescope.builtin')
			vim.keymap.set('n', '<leader>ft', builtin.find_files)
			vim.keymap.set('n', '<leader>th', builtin.help_tags)
			vim.keymap.set('n', '<leader>tg', function()
				builtin.grep_string({ search = vim.fn.input("Grep > ") })
			end)
		end,
	},

	{
		"lmburns/lf.nvim",
		enabled = false,
		lazy = false,
		dependencies = {
			"akinsho/toggleterm.nvim",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			-- Defaults
			require("lf").setup({
				default_cmd = "lf",  -- default `lf` command
				default_action = "edit", -- default action when `Lf` opens a file
				default_actions = {
				                     -- default action keybindings
					["<C-t>"] = "tabedit",
					["<C-x>"] = "split",
					["<C-v>"] = "vsplit",
					["<C-o>"] = "tab drop",
				},

				winblend = 10,    -- psuedotransparency level
				dir = "",         -- directory where `lf` starts ('gwd' is git-working-directory, "" is CWD)
				direction = "float", -- window type: float horizontal vertical
				border = "single", -- border kind: single double shadow curved
				height = 0.90,    -- height of the *floating* window
				width = 0.90,     -- width of the *floating* window
				escape_quit = true, -- map escape to the quit command (so it doesn't go into a meta normal mode)
				focus_on_open = false, -- focus the current file when opening Lf (experimental)
				mappings = true,  -- whether terminal buffer mapping is enabled
				tmux = false,     -- tmux statusline can be disabled on opening of Lf
				highlights = {
					-- highlights passed to toggleterm
					Normal = { guibg = "#1F1F28" },
					NormalFloat = { link = 'Normal', guibg = "#1F1F28" },
					FloatBorder = {
						-- guifg = <VALUE>,
						-- guibg = <VALUE>
					}
				},
				-- Layout configurations
				layout_mapping = "<A-u>", -- resize window with this key

				-- 	views = { -- window dimensions to rotate through
				-- 	{ width = 0.600, height = 0.600 },
				-- 	{
				-- 		width = 1.0 * fn.float2nr(fn.round(0.7 * o.columns)) / o.columns,
				-- 		height = 1.0 * fn.float2nr(fn.round(0.7 * o.lines)) / o.lines,
				-- 	},
				-- 	{ width = 0.800, height = 0.800 },
				-- 	{ width = 0.950, height = 0.950 },
				-- }
			})
			vim.keymap.set("n", "<leader>fl", "<cmd>lua require('lf').start()<CR>", { noremap = true })
		end
	},
}
