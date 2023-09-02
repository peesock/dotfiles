return {
	{
		'nvim-treesitter/nvim-treesitter',
		version = false, -- last release is way too old and doesn't work on Windows
		build = ":TSUpdate",
		-- event = { "BufReadPost", "BufNewFile" },
		config = function()
			require 'nvim-treesitter.configs'.setup {
				-- A list of parser names, or "all" (the five listed parsers should always be installed)
				ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },

				-- Install parsers synchronously (only applied to `ensure_installed`)
				sync_install = false,

				-- Automatically install missing parsers when entering buffer
				-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
				auto_install = true,

				-- List of parsers to ignore installing (for "all")
				-- ignore_install = { "javascript" },

				---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
				-- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

				highlight = {
					enable = true,
					disable = {
						-- "bash",
					},

					-- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
					-- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
					-- the name of the parser)
					-- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
					-- disable = function(lang, buf)
					-- 	local max_filesize = 100 * 1024 -- 100 KB
					-- 	local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					-- 	if ok and stats and stats.size > max_filesize then
					-- 		return true
					-- 	end
					-- end,

					-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
					-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
					-- Using this option may slow down your editor, and you may see some duplicate highlights.
					-- Instead of true it can also be a list of languages
					additional_vim_regex_highlighting = false,
				},
			}
		end
	},

	{
		'nvim-treesitter/nvim-treesitter-context',
		dependencies = 'nvim-treesitter/nvim-treesitter',
		opts = {
			enable = true,         -- Enable this plugin (Can be enabled/disabled later via commands)
			max_lines = 0,         -- How many lines the window should span. Values <= 0 mean no limit.
			min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
			line_numbers = true,
			multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
			trim_scope = 'outer',  -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
			mode = 'cursor',       -- Line used to calculate context. Choices: 'cursor', 'topline'
			-- Separator between context and content. Should be a single character string, like '-'.
			-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
			separator = nil,
			zindex = 20, -- The Z-index of the context window
		}
	},
	-- {
	-- 	"nvim-treesitter/nvim-treesitter",
	-- 	enabled = true,
	-- 	version = false, -- last release is way too old and doesn't work on Windows
	-- 	build = ":TSUpdate",
	-- 	event = { "BufReadPost", "BufNewFile" },
	-- 	dependencies = {
	-- 		{
	-- 			"nvim-treesitter/nvim-treesitter-textobjects",
	-- 			init = function()
	-- 				-- PERF: no need to load the plugin, if we only need its queries for mini.ai
	-- 				local plugin = require("lazy.core.config").spec.plugins["nvim-treesitter"]
	-- 				local opts = require("lazy.core.plugin").values(plugin, "opts", false)
	-- 				local enabled = false
	-- 				if opts.textobjects then
	-- 					for _, mod in ipairs({ "move", "select", "swap", "lsp_interop" }) do
	-- 						if opts.textobjects[mod] and opts.textobjects[mod].enable then
	-- 							enabled = true
	-- 							break
	-- 						end
	-- 					end
	-- 				end
	-- 				if not enabled then
	-- 					require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
	-- 				end
	-- 			end,
	-- 		},
	-- 		{
	-- 			"nvim-treesitter/nvim-treesitter-refactor"
	-- 		},
	--
	-- 	},
	-- 	---@type TSConfig
	-- 	opts = {
	-- 		-- Treesitter folds
	-- 		-- vim.o.foldmethod = 'expr'
	-- 		-- vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
	-- 		-- vim.o.foldlevelstart = 99
	--
	-- 		auto_install = true,
	-- 		highlight = {
	-- 			enable = true,
	-- 			-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
	-- 			-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
	-- 			-- Using this option may slow down your editor, and you may see some duplicate highlights.
	-- 			-- Instead of true it can also be a list of languages
	-- 			additional_vim_regex_highlighting = false,
	-- 		},
	-- 		indent = {
	-- 			enable = false,
	-- 		},
	-- 		incremental_selection = {
	-- 			enable = true,
	-- 			keymaps = {
	-- 				init_selection = "gs",
	-- 				-- NOTE: These are visual mode mappings
	-- 				node_incremental = "gs",
	-- 				node_decremental = "gS",
	-- 				scope_incremental = "<leader>gc",
	-- 			},
	-- 		},
	-- 		-- nvim-treesitter/nvim-treesitter-textobjects
	-- 		textobjects = {
	-- 			select = {
	-- 				enable = true,
	-- 				-- Automatically jump forward to textobj, similar to targets.vim
	-- 				lookahead = true,
	-- 				keymaps = {
	-- 					-- You can use the capture groups defined in textobjects.scm
	-- 					["af"] = "@function.outer",
	-- 					["if"] = "@function.inner",
	-- 					["ac"] = "@class.outer",
	-- 					["ic"] = "@class.inner",
	-- 					["al"] = "@loop.outer",
	-- 					["il"] = "@loop.inner",
	-- 					["aa"] = "@parameter.outer",
	-- 					["ia"] = "@parameter.inner",
	-- 					["uc"] = "@comment.outer",
	--
	-- 					-- Or you can define your own textobjects like this
	-- 					-- ["iF"] = {
	-- 					--     python = "(function_definition) @function",
	-- 					--     cpp = "(function_definition) @function",
	-- 					--     c = "(function_definition) @function",
	-- 					--     java = "(method_declaration) @function",
	-- 					-- },
	-- 				},
	-- 			},
	-- 			swap = {
	-- 				enable = true,
	-- 				swap_next = {
	-- 					["<leader>a"] = "@parameter.inner",
	-- 					["<leader>f"] = "@function.outer",
	-- 					["<leader>e"] = "@element",
	-- 				},
	-- 				swap_previous = {
	-- 					["<leader>A"] = "@parameter.inner",
	-- 					["<leader>F"] = "@function.outer",
	-- 					["<leader>E"] = "@element",
	-- 				},
	-- 			},
	-- 			move = {
	-- 				enable = true,
	-- 				set_jumps = true, -- whether to set jumps in the jumplist
	-- 				goto_next_start = {
	-- 					["]f"] = "@function.outer",
	-- 					["]]"] = "@class.outer",
	-- 				},
	-- 				goto_next_end = {
	-- 					["]F"] = "@function.outer",
	-- 					["]["] = "@class.outer",
	-- 				},
	-- 				goto_previous_start = {
	-- 					["[f"] = "@function.outer",
	-- 					["[["] = "@class.outer",
	-- 				},
	-- 				goto_previous_end = {
	-- 					["[F"] = "@function.outer",
	-- 					["[]"] = "@class.outer",
	-- 				},
	-- 			},
	-- 		},
	-- 		-- windwp/nvim-ts-autotag
	-- 		autotag = {
	-- 			enable = true,
	-- 		},
	-- 		-- nvim-treesitter/playground
	-- 		-- playground = {
	-- 		-- 	enable = true,
	-- 		-- 	disable = {},
	-- 		-- 	updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
	-- 		-- 	persist_queries = false, -- Whether the query persists across vim sessions
	-- 		-- },
	-- 		-- nvim-treesitter/nvim-treesitter-refactor
	-- 		refactor = {
	-- 			highlight_definitions = { enable = true },
	-- 			-- highlight_current_scope = { enable = false },
	-- 		},
	-- 		context_commentstring = {
	-- 			enable = true,
	-- 			enable_autocmd = false,
	-- 		},
	-- 	},
	-- 	---@param opts TSConfig
	-- 	config = function(opts)
	-- 		require("nvim-treesitter.configs").setup(opts)
	-- 	end,
	-- },
}
