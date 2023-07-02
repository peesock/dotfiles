return {
	"hkupty/iron.nvim",
	-- enabled = false,
	config = function()
		local iron = require("iron.core")
		local view = require("iron.view")
		local format_plus = function (lines)
			for i, v in ipairs(lines) do
				-- remove spaces, tabs
				v = v:gsub('^%s+', '')
				v = v:gsub('^\t+', '')
				-- remove spaces at end of line
				v = v:gsub('%s+$', '')
				-- remove line break and extra spaces eventually
				v = v:gsub([[\$]], '')
				v = v:gsub('%s+$', '')
				lines[i] = v
			end
			lines[#lines] = lines[#lines] .. '\13'
			return lines
		end
		iron.setup({
			config = {
				-- Whether a repl should be discarded or not
				scratch_repl = true,
				-- Your repl definitions come here
				repl_definition = {
					c = {
						command = "tcc -run -",
						format = format_plus,
					},
					lua = {
						command = "lua",
						format = format_plus,
					},

					sh = {
						-- Can be a table or a function that
						-- returns a table (see below)
						command = { "dash" },
						format = format_plus,
					},
					lisp = {
						command = { "clisp" },
					},
				},
				-- How the repl window will be displayed
				-- See below for more information
				repl_open_cmd = view.split.vertical.botright(0.30),
			},
			-- Iron doesn't set keymaps by default anymore.
			-- You can set them here or manually add keymaps to the functions in iron.core
			keymaps = {
				send_motion = "<leader>rs",
				visual_send = "<leader>r",
				send_file = "<leader>rf",
				send_line = "<leader>rr",
				-- send_mark = "<leader>rms",
				-- mark_motion = "<leader>rm",
				-- mark_visual = "<leader>rm",
				-- remove_mark = "<leader>rmd",
				cr = "<leader>r<cr>",
				-- interrupt = "<leader>rs<leader>r",
				exit = "<leader>rq",
				clear = "<leader>rc",
			},
			-- If the highlight is on, you can change how it looks
			-- For the available options, check nvim_set_hl
			highlight = {
				italic = false,
			},
			ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
		})
		-- iron also has a list of commands, see :h iron-commands for all available commands
		-- vim.keymap.set("n", "<space>r", "<cmd>IronRepl<cr>")
		-- vim.keymap.set("n", "<space>rs", "<cmd>IronRepl<cr>")
		vim.keymap.set("n", "<leader>rR", "<cmd>IronRestart<cr><cmd>IronRepl<cr>")
		-- vim.keymap.set("n", "<space>rf", "<cmd>IronFocus<cr>")
		-- vim.keymap.set("n", "<space>rh", "<cmd>IronHide<cr>")
	end,
}
