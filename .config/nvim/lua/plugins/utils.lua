return {
	{
		'echasnovski/mini.clue',
		config = function()
			local miniclue = require('mini.clue')
			miniclue.setup({
				triggers = {
					-- Leader triggers
					{ mode = 'n', keys = '<Leader>' },
					{ mode = 'x', keys = '<Leader>' },
					-- Built-in completion
					{ mode = 'i', keys = '<C-x>' },
					-- `g` key
					{ mode = 'n', keys = 'g' },
					{ mode = 'x', keys = 'g' },
					-- Marks
					{ mode = 'n', keys = "'" },
					{ mode = 'n', keys = '`' },
					{ mode = 'x', keys = "'" },
					{ mode = 'x', keys = '`' },
					-- Registers
					{ mode = 'n', keys = '"' },
					{ mode = 'x', keys = '"' },
					{ mode = 'i', keys = '<C-r>' },
					{ mode = 'c', keys = '<C-r>' },
					-- Window commands
					{ mode = 'n', keys = '<C-w>' },
					-- `z` key
					{ mode = 'n', keys = 'z' },
					{ mode = 'x', keys = 'z' },
				},

				clues = {
					-- Enhance this by adding descriptions for <Leader> mapping groups
					-- miniclue.gen_clues.builtin_completion(),
					miniclue.gen_clues.g(),
					miniclue.gen_clues.marks(),
					miniclue.gen_clues.registers(),
					miniclue.gen_clues.windows(),
					miniclue.gen_clues.z(),
				},

				window = {
					config = {
						width = "auto",
						row = "auto",
						col = "auto"
					}
				},
			})
		end,
	},

	{
		'numToStr/Comment.nvim',
		opts = {
		},
	},

	{
		'echasnovski/mini.indentscope',
		event = 'LspAttach', -- it looks ugly outside of code
		config = function()
			require('mini.indentscope').setup({
				-- Draw options
				draw = {
					delay = 0,
					animation = require('mini.indentscope').gen_animation.none(),
					priority = 2,
				},

				-- Module mappings. Use `''` (empty string) to disable one.
				mappings = {
					-- Textobjects
					object_scope = 'ii',
					object_scope_with_border = 'ai',
					-- Motions (jump to respective border line; if not present - body line)
					goto_top = '[i',
					goto_bottom = ']i',
				},

				-- Options which control scope computation
				options = {
					-- Type of scope's border: which line(s) with smaller indent to
					-- categorize as border. Can be one of: 'both', 'top', 'bottom', 'none'.
					border = 'both',
					-- Whether to use cursor column when computing reference indent.
					-- Useful to see incremental scopes with horizontal cursor movements.
					indent_at_cursor = true,
					-- Whether to first check input line to be a border of adjacent scope.
					-- Use it if you want to place cursor on function header to get scope of
					-- its body.
					try_as_border = true,
				},

				-- Which character to use for drawing scope indicator
				symbol = '│',
			})
		end,
	},

	{
		'echasnovski/mini.jump',
		config = function()
			require('mini.jump').setup({
				-- Delay values (in ms) for different functionalities. Set any of them to
				-- a very big number (like 10^7) to virtually disable.
				delay = {
					-- Delay between jump and highlighting all possible jumps
					highlight = 250,

					-- Delay between jump and automatic stop if idle (no jump is done)
					idle_stop = 0,
				},
			})
		end,
	},

	{
		'echasnovski/mini.move',
		config = function()
			require('mini.move').setup({
				-- Module mappings. Use `''` (empty string) to disable one.
				mappings = {
					-- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
					left = 'H',
					right = 'L',
					down = 'J',
					up = 'K',
					-- Move current line in Normal mode
					line_left = '',
					line_right = '',
					line_down = '',
					line_up = '',
				},

				-- Options which control moving behavior
				options = {
					-- Automatically reindent selection during linewise vertical move
					reindent_linewise = true,
				},
			})
		end,
	},

	{
		'tpope/vim-surround',
	},

	{
		"andymass/vim-matchup",
	},

	{
		"kovetskiy/sxhkd-vim",
	},

	{
		"mbbill/undotree",
		config = function()
			mapper('n', '<leader>u', vim.cmd.UndotreeToggle, "Toggle Undotree")
			vim.g.undotree_WindowLayout = 2
			vim.g.undotree_DiffpanelHeight = 8
			vim.g.undotree_SetFocusWhenToggle = 1
			-- remove leading whitespace
			vim.g.undotree_DiffCommand = [[sh -c 'diff "$@" | sed "s/\([<>]\)\s*/\1/" | sed "s/\s*\$//"' _]]
			vim.g.undotree_HelpLine = 0
			vim.g.undotree_ShortIndicators = 1
			vim.g.undotree_SplitWidth = 25
			-- vim.g.undotree_RelativeTimestamp = 0
		end,
	},

	{
		'j-hui/fidget.nvim',
		-- enabled = false,
		-- event = "LspAttach",
		opts = {
			notification = {
				window = {
					winblend = 0,
				},
			}
		},
	},

}
