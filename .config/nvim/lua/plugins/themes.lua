local g = vim.g

return {
	{
		'mvllow/naif.nvim',
		enabled = false,
		config = function ()
			require("naif").setup()
		end
	},

	{
		"sainnhe/sonokai",
		-- lazy = true,
		config = function()
			g.sonokai_style = "andromeda"
			g.sonokai_enable_italic = 1
			g.sonokai_transparent_background = 1
		end,
	},

	{
		"NLKNguyen/papercolor-theme",
		-- lazy = true,
		config = function()
			g["PaperColor_Theme_Options"] = {
				["theme"] = {
					["default"] = {
						["transparent_background"] = 1,
						["allow_bold"] = 1,
						["allow_italic"] = 1,
					},
				},
			}
		end,
	},

	{
		"olimorris/onedarkpro.nvim",
		-- lazy = true,
		opts = {
			options = {
				transparency = true,
			},
			styles = {
				types = "NONE",
				methods = "NONE",
				numbers = "NONE",
				strings = "NONE",
				comments = "italic",
				keywords = "bold,italic",
				constants = "NONE",
				functions = "italic",
				operators = "NONE",
				variables = "NONE",
				parameters = "NONE",
				conditionals = "italic",
				-- virtual_text = "NONE",
			},
		},
	},

	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"kyazdani42/nvim-web-devicons",
		},
		opts = {
			options = {
				icons_enabled = true,
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				ignore_focus = {},
				always_divide_middle = true,
				globalstatus = false,
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
				},
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "filename" },
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			winbar = {},
			inactive_winbar = {},
			extensions = {},
		},
		-- config = function(_, opts)
		-- 	require("lualine").setup(opts)
		-- end,
	},

	{
		"rebelot/kanagawa.nvim",
		opts = {
			compile = false, -- enable compiling the colorscheme
			undercurl = true, -- enable undercurls
			commentStyle = { italic = true },
			functionStyle = {},
			keywordStyle = { italic = true },
			statementStyle = { bold = true },
			typeStyle = {},
			transparent = true, -- do not set background color
			dimInactive = false, -- dim inactive window `:h hl-NormalNC`
			terminalColors = true, -- define vim.g.terminal_color_{0,17}
			colors = {
			                     -- add/modify theme and palette colors
				palette = {},
				theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
			},
			overrides = function(colors) -- add/modify highlights
				return {}
			end,
			theme = "wave",  -- Load "wave" theme when 'background' option is not set
			background = {
			                 -- map the value of 'background' option to a theme
				dark = "wave", -- try "dragon" !
				light = "lotus"
			},
		}
	},

	{
		"kdheepak/tabline.nvim",
		opts = {
			-- Defaults configuration options
			enable = false,
			options = {
				-- If lualine is installed tabline will use separators configured in lualine by default.
				-- These options can be used to override those settings.
				-- section_separators = { "", "" },
				-- component_separators = { "", "" },
				max_bufferline_percent = 66, -- set to nil by default, and it uses vim.o.columns * 2/3
				show_tabs_always = true, -- this shows tabs only when there are more than one tab or if the first tab is named
				show_devicons = true, -- this shows devicons in buffer section
				show_bufnr = false, -- this appends [bufnr] to buffer section,
				show_filename_only = false, -- shows base filename only instead of relative path in filename
				modified_icon = "", -- change the default modified icon
				modified_italic = true, -- set to true by default; this determines whether the filename turns italic if modified
				show_tabs_only = false, -- this shows only tabs instead of tabs + buffers
			},
		},
		-- vim.cmd([[
		-- set guioptions-=e " Use showtabline in gui vim
		-- set sessionoptions+=tabpages,globals " store tabpages and globals in session
		-- ]])
	},
}
