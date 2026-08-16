-- Globals

-- set map, with easy description
function mapper(mode, keys, func, desc, opts)
	local common = {
		desc = desc
	}
	if opts then
		for k, v in pairs(opts) do
			common[k] = v
		end
	end
	vim.keymap.set(mode, keys, func, common)
end

local g = vim.g
local opt = vim.opt

-- set leader
g.mapleader = " "
g.maplocalleader = " "

-- Visual
opt.conceallevel = 0 -- Don't hide quotes in markdown
opt.cmdheight = 1
opt.pumheight = 10
opt.showmode = false
opt.showtabline = 0
opt.title = true
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
-- opt.signcolumn = "no"
-- opt.numberwidth = 4
opt.cursorline = true
opt.cursorlineopt = "both"
opt.laststatus = 0
opt.list = true
opt.listchars = "tab:│ ,trail:-,lead:-,nbsp:+,"
-- │ ┆ ┊ ·
opt.timeoutlen = 1000
-- opt.colorcolumn = "80"
opt.textwidth = 100
opt.formatoptions = "qj"

-- Behavior
opt.hlsearch = true
opt.ignorecase = true -- Ignore case when using lowercase in search
opt.smartcase = true -- But don't ignore it when using upper case
opt.smarttab = true
opt.smartindent = true
opt.expandtab = false -- Convert tabs to spaces
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 8 -- Minimum offset in lines to screen borders
opt.sidescrolloff = 8
-- opt.clipboard = "unnamedplus"
vim.cmd.filetype("plugin", "on")
-- opt.omnifunc = "syntaxcomplete#Complete"
opt.swapfile = false
-- opt.backup = true
-- opt.backupdir = "/tmp/vim"
opt.undofile = true
g.nofixendofline = true
g.rust_recommended_style = false
g.zig_recommended_style = false
g.hare_recommended_style = false

-- Vim specific
opt.hidden = true -- Do not save when switching buffers
opt.fileencoding = "utf-8"
opt.spell = false
opt.spelllang = "en_us"
-- opt.completeopt = "menuone,noinsert,noselect"
-- opt.wildmode = "longest,list,full" -- Display auto-complete in Command Mode
-- opt.updatetime = 50 -- Delay until write to Swap and HoldCommand event
-- g.do_file_type_lua   = 1

-- g.loaded_matchit = 1 -- disable the stupidass slow matchit plugin POS
-- g.loaded_matchparen = 1

require('plugins')

-- binds

-- map('n', '<leader>s', '<CMD>!clear && shellcheck -x %<CR>')

-- navigation
mapper({'n',}, '<leader>fv', vim.cmd.Ex, 'Open netrw')

-- keep cursor in middle of screen
-- mapper('n', '<C-f>', '<C-f>M')
-- mapper('n', '<C-b>', '<C-b>M')
-- mapper('n', '<C-d>', '<C-d>M')
-- mapper('n', '<C-u>', '<C-u>M')

-- mapper('n', 'n', 'nzzzv')
-- mapper('n', 'N', 'Nzzzv')

-- mapper("n", "J", "mzJ`z") -- keep cursor in same spot when Jing

-- yank and delete to system clipboard
mapper({"n", "v"}, "<leader>y", "\"+y", 'Yank to sys')
mapper({"n", "v"}, "<leader>d", "\"_d", 'Cut without yank')
mapper({'n', 'v',}, '<leader>p', '"_dP', 'Paste without yank')

mapper('n', '<leader>vo', '<CMD>setlocal spell! spelllang=en_us<CR>', 'Toggle spellcheck')
mapper({'n',}, 'S', ':%s//g<left><left>')
mapper({'v',}, 'S', ':s//g<left><left>')
mapper("n", "<leader>x", "<cmd>!chmod +x %<CR>", 'Make file executable', { silent = true })


-- autocmd

-- Restore cursor position
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
	pattern = { "*" },
	callback = function()
		vim.api.nvim_exec('silent! normal! g`"zvzz', false)
	end,
})


vim.cmd[[ autocmd FileType * setlocal formatoptions-=o ]]
