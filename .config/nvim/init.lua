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

-- Local aliases
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

-- Behavior
opt.hlsearch = false
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
opt.mouse = "a"
-- opt.clipboard = "unnamedplus"
vim.cmd.filetype("plugin", "on")
opt.omnifunc = "syntaxcomplete#Complete"
opt.swapfile = false
-- opt.backup = true
-- opt.backupdir = "/tmp/vim"
opt.undodir = os.getenv("HOME") .. "/.local/share/nvim/undodir"
opt.undofile = true

-- Vim specific
opt.hidden = true -- Do not save when switching buffers
opt.fileencoding = "utf-8"
opt.spell = false -- As of v0.8.0 it only checks comments
opt.spelllang = "en_us"
opt.completeopt = "menuone,noinsert,noselect"
opt.wildmode = "longest,list,full" -- Display auto-complete in Command Mode
opt.updatetime = 50 -- Delay until write to Swap and HoldCommand event
-- g.do_file_type_lua   = 1

-- Plugin specific
g.loaded_matchit = 1		-- disable the stupidass slow matchit plugin POS
g.loaded_matchparen = 1
-- replace netrw with lf
g.netrw = 1
g.lf_netrw = 1

-- Example for configuring Neovim to load user-installed installed Lua rocks:
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"

require('bootstrap')

-- binds

-- map('n', '<leader>s', '<CMD>!clear && shellcheck -x %<CR>')

-- navigation
mapper({'n',}, '<leader>fv', vim.cmd.Ex, 'Open netrw')

-- keep cursor in middle of screen
mapper('n', '<C-f>', '<C-f>M')
mapper('n', '<C-b>', '<C-b>M')
mapper('n', '<C-d>', '<C-d>M')
mapper('n', '<C-u>', '<C-u>M')
-- mapper('n', 'n', 'nzzzv')
-- mapper('n', 'N', 'Nzzzv')
mapper("n", "J", "mzJ`z") -- keep cursor in same spot when Jing

-- yank and delete to system clipboard
mapper({"n", "v"}, "<leader>y", "\"+y", 'Yank to sys')
mapper({"n", "v"}, "<leader>d", "\"_d", 'Cut without yank')
mapper({'n', 'v',}, '<leader>p', '"_dP', 'Paste without yank') -- paste without overwriting clipboard

-- move lines in visual mode; now taken by mini.move
-- mapper("v", "J", ":m '>+1<CR>gv=gv")
-- mapper("v", "K", ":m '<-2<CR>gv=gv")

mapper('n', '<leader>vo', '<CMD>setlocal spell! spelllang=en_us<CR>', 'Toggle spellcheck')
mapper({'n',}, 'S', ':%s//g<left><left>') mapper({'v',}, 'S', ':s//g<left><left>')
mapper("n", "<leader>x", "<cmd>!chmod +x %<CR>", 'Make file executable', { silent = true })


-- autocmd

-- vim.cmd[[autocmd VimLeave *.tex !texclear %]]
-- Enable Goyo by default for mutt writing
vim.cmd[[
autocmd BufRead,BufNewFile /tmp/neomutt* let g:goyo_width=80
autocmd BufRead,BufNewFile /tmp/neomutt* :Goyo | set bg=dark
autocmd BufRead,BufNewFile /tmp/neomutt* map ZZ :Goyo\|x!<CR>
autocmd BufRead,BufNewFile /tmp/neomutt* map ZQ :Goyo\|q!<CR>
]]

-- Restore cursor position
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
	pattern = { "*" },
	callback = function()
		vim.api.nvim_exec('silent! normal! g`"zvzz', false)
	end,
})


-- Disables automatic commenting on newline:
-- vim.cmd[[ autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o ]]
vim.cmd[[ autocmd FileType * setlocal formatoptions-=o ]]
