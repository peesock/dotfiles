return {
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
		"numToStr/Comment.nvim",
		opts = {
			---Add a space b/w comment and the line
			padding = true,
			---Whether the cursor should stay at its position
			sticky = true,
			---Lines to be ignored while (un)comment
			ignore = nil,
			---LHS of toggle mappings in NORMAL mode
			toggler = {
				---Line-comment toggle keymap
				line = 'gcc',
				---Block-comment toggle keymap
				block = 'gbc',
			},
			---LHS of operator-pending mappings in NORMAL and VISUAL mode
			opleader = {
				---Line-comment keymap
				line = 'gc',
				---Block-comment keymap
				block = 'gb',
			},
			---LHS of extra mappings
			extra = {
				---Add comment on the line above
				above = 'gcO',
				---Add comment on the line below
				below = 'gco',
				---Add comment at the end of line
				eol = 'gcA',
			},
			---Enable keybindings
			---NOTE: If given `false` then the plugin won't create any mappings
			mappings = {
				---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
				basic = true,
				---Extra mapping; `gco`, `gcO`, `gcA`
				extra = true,
			},
			---Function to call before (un)comment
			pre_hook = nil,
			---Function to call after (un)comment
			post_hook = nil,
		}
	},

	{
		"folke/which-key.nvim",
		config = function()
			-- vim.o.timeout = true
			-- vim.o.timeoutlen = 400
			require("which-key").setup({
				plugins = {
					marks = true, -- shows a list of your marks on ' and `
					registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
					spelling = {
						enabled = false, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
						suggestions = 20, -- how many suggestions should be shown in the list?
					},
					-- the presets plugin, adds help for a bunch of default keybindings in Neovim
					-- No actual key bindings are created
					presets = {
						operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
						motions = true, -- adds help for motions
						text_objects = true, -- help for text objects triggered after entering an operator
						windows = true, -- default bindings on <c-w>
						nav = true, -- misc bindings to work with windows
						z = true, -- bindings for folds, spelling and others prefixed with z
						g = true, -- bindings for prefixed with g
					},
				},
				-- add operators that will trigger motion and text object completion
				-- to enable all native operators, set the preset / operators plugin above
				operators = { gc = "Comments" },
				key_labels = {
					-- override the label used to display some keys. It doesn't effect WK in any other way.
					-- For example:
					-- ["<space>"] = "SPC",
					-- ["<cr>"] = "RET",
					-- ["<tab>"] = "TAB",
				},
				icons = {
					breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
					separator = "➜", -- symbol used between a key and it's label
					group = "+", -- symbol prepended to a group
				},
				popup_mappings = {
					scroll_down = "<c-d>", -- binding to scroll down inside the popup
					scroll_up = "<c-u>", -- binding to scroll up inside the popup
				},
				window = {
					border = "none", -- none, single, double, shadow
					position = "bottom", -- bottom, top
					margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
					padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
					winblend = 0,
				},
				layout = {
					height = { min = 4, max = 25 }, -- min and max height of the columns
					width = { min = 20, max = 50 }, -- min and max width of the columns
					spacing = 3, -- spacing between columns
					align = "left", -- align columns left, center or right
				},
				ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
				hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
				show_help = true, -- show help message on the command line when the popup is visible
				show_keys = true, -- show the currently pressed key and its label as a message in the command line
				triggers = "auto", -- automatically setup triggers
				-- triggers = {"<leader>"} -- or specify a list manually
				triggers_blacklist = {
					-- list of mode / prefixes that should never be hooked by WhichKey
					-- this is mostly relevant for key maps that start with a native binding
					-- most people should not need to change this
					i = { "j", "k" },
					v = { "j", "k" },
				},
				-- disable the WhichKey popup for certain buf types and file types.
				-- Disabled by deafult for Telescope
				disable = {
					buftypes = {},
					filetypes = { "TelescopePrompt" },
				},
			})
		end,
	},
	{
		"mbbill/undotree",
		config = function()
			vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
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
		'vigoux/notifier.nvim',
		-- enabled = false,
		opts = {
			ignore_messages = {}, -- Ignore message from LSP servers with this name
			-- status_width = something, -- COmputed using 'columns' and 'textwidth'
			components = {        -- Order of the components to draw from top to bottom (first nvim notifications, then lsp)
				"nvim",             -- Nvim notifications (vim.notify and such)
				"lsp"               -- LSP status updates
			},
			notify = {
				clear_time = 5000,           -- Time in milliseconds before removing a vim.notify notification, 0 to make them sticky
				min_level = vim.log.levels.INFO, -- Minimum log level to print the notification
			},
			component_name_recall = false, -- Whether to prefix the title of the notification by the component name
			zindex = 50,                   -- The zindex to use for the floating window. Note that changing this value may cause visual bugs with other windows overlapping the notifier window.
		},

		{
			'j-hui/fidget.nvim',
			enabled = false,
			config = function()
				require("fidget").setup{}
			end,
		},
	},

	{
		'echasnovski/mini.nvim', version = false,
		config = function()
			require('mini.ai').setup()
		end,
	},

}
