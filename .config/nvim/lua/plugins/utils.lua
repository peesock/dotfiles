return {
	{
		'echasnovski/mini.nvim', version = false,
		config = function()
			require('mini.ai').setup()
			require('mini.align').setup({
				mappings = {
					start = 'gA',
				},
			})
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
					miniclue.gen_clues.builtin_completion(),
					miniclue.gen_clues.g(),
					miniclue.gen_clues.marks(),
					miniclue.gen_clues.registers(),
					miniclue.gen_clues.windows(),
					miniclue.gen_clues.z(),
				},
			})
			require('mini.bufremove').setup()
			require('mini.comment').setup({
				-- Options which control module behavior
				options = {
					-- Function to compute custom 'commentstring' (optional)
					custom_commentstring = nil,
					ignore_blank_line = true,
					-- Whether to recognize as comment only lines without indent
					start_of_line = false,
					-- Whether to ensure single space pad for comment parts
					pad_comment_parts = true,
				},

				-- Module mappings. Use `''` (empty string) to disable one.
				mappings = {
					comment = 'gc',
					comment_line = 'gcc',
					-- Define 'comment' textobject (like `dgc` - delete whole comment block)
					textobject = 'gc',
				},

				-- Hook functions to be executed at certain stage of commenting
				hooks = {
					-- Before successful commenting. Does nothing by default.
					pre = function() end,
					-- After successful commenting. Does nothing by default.
					post = function() end,
				},

			})
			vim.keymap.set('n', 'gco', 'o.<Esc>gcc$s', { remap = true, })
			vim.keymap.set('n', 'gcO', 'O.<Esc>gcc$s', { remap = true, })
			vim.keymap.set('n', 'gcA', 'o.<Esc>gcckJ$s', { remap = true, })
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

				-- │ ╎ ┆ ┊
				-- Which character to use for drawing scope indicator
				symbol = '│',

			})
			local hipatterns = require('mini.hipatterns')
			hipatterns.setup({
				highlighters = {
					-- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
					fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
					hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
					todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
					note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },
					-- Highlight hex color strings (`#rrggbb`) using that color
					hex_color = hipatterns.gen_highlighter.hex_color(),
				},
			})
			require('mini.pairs').setup()
			vim.g.minipairs_disable = true
			vim.keymap.set('n', '<leader>a', function()
				vim.g.minipairs_disable = not vim.g.minipairs_disable
				if vim.g.minipairs_disable then
					print 'autopairs disabled'
				else
					print 'autopairs enabled'
				end
			end, { desc = 'Toggle autopairs'})
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
			-- mini.jump2d :flushed:
		end,
	},

	{
		"andymass/vim-matchup",
		config = function()

		end,
	},
	{
		"kovetskiy/sxhkd-vim",
	},
	{
		"waycrate/swhkd-vim",
	},

	{
		"junegunn/goyo.vim",
	},

	{
		"norcalli/nvim-colorizer.lua",
	},

	{
		"mbbill/undotree",
		config = function()
			vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
			vim.g.undotree_WindowLayout = 2
			vim.g.undotree_SetFocusWhenToggle = 1
			vim.g.undotree_DiffCommand = [[sh -c 'diff "$@" | sed "s/\([<>]\)\s*/\1/" | sed "s/\s*\$//"' _]]
			vim.g.undotree_HelpLine = 0
		end,
	},

	{
		'gelguy/wilder.nvim',
		config = function()
			require('wilder').setup({
				modes = {':', '/', '?'}
			})
		end,
	},

	{
		'j-hui/fidget.nvim',
		-- enabled = false,
		tag = "legacy",
		event = "LspAttach",
		opts = {
		},
	},

}
