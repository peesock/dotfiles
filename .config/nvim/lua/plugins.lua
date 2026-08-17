local hook = function(ev)
	local name, kind = ev.data.spec.name, ev.data.kind
	-- Run build script after plugin's code has changed
	if name == 'blink.cmp' and (kind == 'install' or kind == 'update') then
		vim.cmd.packadd('blink.lib')
		vim.cmd.packadd('blink.cmp')
		require('blink.cmp').build():pwait()
	end

	if name == 'nvim-treesitter' and kind == 'update' then
		if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
		vim.cmd('TSUpdate')
	end
end
vim.api.nvim_create_autocmd('PackChanged', { callback = hook })

vim.pack.add({
	{ src = 'https://github.com/neovim/nvim-lspconfig', },
	{ src = 'https://github.com/nvim-treesitter/nvim-treesitter', },
	{ src = 'https://github.com/mason-org/mason-lspconfig.nvim', },
	{ src = 'https://github.com/mason-org/mason.nvim', },
	{ src = 'https://github.com/saghen/blink.cmp', },
	{ src = 'https://github.com/saghen/blink.lib', },
	{ src = 'https://github.com/nvim-lualine/lualine.nvim', },
	{ src = 'https://github.com/kyazdani42/nvim-web-devicons', },
	{ src = 'https://github.com/folke/which-key.nvim', },
	{ src = 'https://github.com/tpope/vim-commentary', },
	{ src = 'https://github.com/olimorris/onedarkpro.nvim', },
	{ src = 'https://github.com/nvim-mini/mini.indentscope', },
	{ src = 'https://github.com/nvim-mini/mini.move', },
	{ src = 'https://github.com/j-hui/fidget.nvim', },
	{ src = 'https://github.com/lewis6991/async.nvim', },
})

async = require('async')

require('lsp')

vim.cmd.packadd('nvim.undotree')
mapper('n', '<leader>u', vim.cmd.Undotree, "Toggle Undotree")
require('mason').setup()
require('mason-lspconfig').setup()
require('blink.cmp').setup()
require('lualine').setup()
require('which-key').setup()
require('onedarkpro').setup({
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
})
require('mini.indentscope').setup({
	draw = {
		animation = require('mini.indentscope').gen_animation.none(),
	},
	mappings = {
		object_scope = '',
		object_scope_with_border = '',
		goto_top = '',
		goto_bottom = '',
	},
	options = {
		try_as_border = true,
	},
	symbol = '│',
})

require('mini.move').setup({
	mappings = {
		left = 'H',
		right = 'L',
		down = 'J',
		up = 'K',
		line_left = '',
		line_right = '',
		line_down = '',
		line_up = '',
	},
})
require('fidget').setup()
