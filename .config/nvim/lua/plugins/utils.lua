return {
	{
		'echasnovski/mini.ai',
		config = function()
			require('mini.ai').setup()
		end,
	},

	{
		'echasnovski/mini.align',
		config = function()
			require('mini.align').setup({
				mappings = {
					start = 'gA',
				},
			})
		end,
	},

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
					miniclue.gen_clues.builtin_completion(),
					miniclue.gen_clues.g(),
					miniclue.gen_clues.marks(),
					miniclue.gen_clues.registers(),
					miniclue.gen_clues.windows(),
					miniclue.gen_clues.z(),
				},
			})
		end,
	},

	{
		'echasnovski/mini.bufremove',
		config = function()
			require('mini.bufremove').setup()
		end,
	},

	{
		'echasnovski/mini.comment',
		config = function()
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
			mapper('n', 'gco', 'o.<Esc>gcc$s', "Comment below", { remap = true, })
			mapper('n', 'gcO', 'O.<Esc>gcc$s', "Comment above", { remap = true, })
			mapper('n', 'gcA', 'o.<Esc>gcckJ$s', "Comment append", { remap = true, })
		end,
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
		'echasnovski/mini.pairs',
		config = function()
			require('mini.pairs').setup()
			vim.g.minipairs_disable = true
			mapper({'i','n'}, '<m-a>', function()
				vim.g.minipairs_disable = not vim.g.minipairs_disable
				if vim.g.minipairs_disable then
					print 'autopairs disabled'
				else
					print 'autopairs enabled'
				end
			end, 'Toggle autopairs')
		end
	},

	{
		'tpope/vim-surround',
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
