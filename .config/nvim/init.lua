-- set leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Visual
vim.opt.conceallevel = 0 -- Don't hide quotes in markdown
vim.opt.cmdheight = 1
vim.opt.pumheight = 10
vim.opt.showmode = false
vim.opt.showtabline = 0 -- Always not show tabline
vim.opt.title = true
vim.opt.termguicolors = true -- Use true colors, required for some plugins
vim.opt.number = true
vim.opt.relativenumber = true
-- vim.opt.signcolumn = "no"
-- vim.opt.numberwidth = 4
vim.opt.cursorline = true
vim.opt.cursorlineopt = "both"
vim.opt.laststatus = 0
vim.opt.list = true
vim.opt.listchars = "tab:│ ,trail:-,lead:-,nbsp:+,"
-- │ ┆ ┊
vim.opt.timeoutlen = 1000
-- vim.opt.colorcolumn = "80"

-- Behavior
vim.opt.hlsearch = false
vim.opt.ignorecase = true -- Ignore case when using lowercase in search
vim.opt.smartcase = true -- But don't ignore it when using upper case
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.expandtab = false -- Convert tabs to spaces.
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.scrolloff = 8 -- Minimum offset in lines to screen borders
vim.opt.sidescrolloff = 8
vim.opt.mouse = "a"
-- vim.opt.clipboard = "unnamedplus"
vim.cmd.filetype("plugin", "on")
vim.opt.omnifunc = "syntaxcomplete#Complete"
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.local/share/nvim/undodir"
vim.opt.undofile = true

-- Vim specific
vim.opt.hidden = true -- Do not save when switching buffers
vim.opt.fileencoding = "utf-8"
vim.opt.spell = false -- As of v0.8.0 it only checks comments
vim.opt.spelllang = "en_us"
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.wildmode = "longest,list,full" -- Display auto-complete in Command Mode
vim.opt.updatetime = 50 -- Delay until write to Swap and HoldCommand event
-- g.do_file_type_lua   = 1

-- Plugin specific
vim.g.loaded_matchit = 1		-- disable the stupidass slow matchit plugin POS
vim.g.loaded_matchparen = 1
-- replace netrw with lf
vim.g.netrw = 1
vim.g.lf_netrw = 1

require('bootstrap')

-- binds

-- map('n', '<leader>s', '<CMD>!clear && shellcheck -x %<CR>')

-- navigation
vim.keymap.set({'n',}, '<leader>fv', vim.cmd.Ex)

-- keep cursor in middle of screen
vim.keymap.set('n', '<C-f>', '<C-f>M')
vim.keymap.set('n', '<C-b>', '<C-b>M')
vim.keymap.set('n', '<C-d>', '<C-d>M')
vim.keymap.set('n', '<C-u>', '<C-u>M')
-- vim.keymap.set('n', 'n', 'nzzzv')
-- vim.keymap.set('n', 'N', 'Nzzzv')
vim.keymap.set("n", "J", "mzJ`z") -- keep cursor in same spot when Jing

-- yank and delete to system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", "\"+y")
vim.keymap.set({"n", "v"}, "<leader>d", "\"_d")
vim.keymap.set({'n', 'v',}, '<leader>p', '"_dP') -- paste without overwriting clipboard

-- move lines in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set('n', '<leader>vo', '<CMD>setlocal spell! spelllang=en_us<CR>')
vim.keymap.set({'n',}, 'S', ':%s//g<left><left>') vim.keymap.set({'v',}, 'S', ':s//g<left><left>')
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })


-- autocmd

-- vim.cmd[[autocmd VimLeave *.tex !texclear %]]
-- Enable Goyo by default for mutt writing
vim.cmd[[
autocmd BufRead,BufNewFile /tmp/neomutt* let g:goyo_width=80
autocmd BufRead,BufNewFile /tmp/neomutt* :Goyo | set bg=dark
autocmd BufRead,BufNewFile /tmp/neomutt* map ZZ :Goyo\|x!<CR>
autocmd BufRead,BufNewFile /tmp/neomutt* map ZQ :Goyo\|q!<CR>
]]

-- Automatically deletes all trailing whitespace and newlines at end of file on save. & reset cursor position
-- vim.cmd[[
-- autocmd BufWritePre * let currPos = getpos(".")
-- autocmd BufWritePre * %s/\n\+\%$//e
-- autocmd BufWritePre *.[ch] %s/\%$/\r/e
-- autocmd BufWritePre * cal cursor(currPos[1], currPos[2])
-- ]]
-- autocmd BufWritePre * %s/\s\+$//e

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
