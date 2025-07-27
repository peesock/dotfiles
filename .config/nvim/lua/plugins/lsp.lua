return {
	{
		'neovim/nvim-lspconfig',
		config = function()
			local icons = require("icons") -- from LunarVim
			vim.diagnostic.config({
				float = {
					source = 'always',
					style = 'minimal',
					border = "rounded",
					focusable = false,
				},
				-- severity: 4 is lowest severity, 1 is highest
				virtual_text = {
					severity = { min = 2, },
					spacing = 2,
				},
				underline = {
					severity = { min = 3, },
				},
				signs = {
					severity = { min = 4 },
				},
				severity_sort = true,
				update_in_insert = true,
			})

			local signs = {
				Error = icons.diagnostics.Error,
				Warn = icons.diagnostics.Warning,
				Info = icons.diagnostics.Information,
				Hint = icons.diagnostics.Hint,
			}

			local signs_active = false
			local function signwise(active)
				if active then
					for type, icon in pairs(signs) do
						local hl = "DiagnosticSign" .. type
						vim.diagnostic.config({
							signs = {
								text = icon,
								texthl = hl,
								numhl = "none",
							}
						})
					end
					vim.opt.signcolumn = "yes:1"
					vim.opt.numberwidth = 1
				else
					for type, icon in pairs(signs) do
						local hl = "DiagnosticSign" .. type
						vim.diagnostic.config({
							signs = {
								text = icon,
								texthl = hl,
								numhl = hl,
							}
						})
					end
					vim.opt.signcolumn = "no"
					vim.opt.numberwidth = 4
				end
			end
			signwise(signs_active)

			local diagnostics_active = true
			local function diagnostical(active)
				if active then
					vim.diagnostic.enable()
					vim.diagnostic.show()
					signwise(signs_active)
				else
					signwise(false)
					vim.diagnostic.enable(false)
					vim.diagnostic.hide()
				end
			end
			diagnostical(diagnostics_active)

			-- mapper("n", "K", function() vim.lsp.buf.hover() end, "")
			mapper("n", "gd", function() vim.lsp.buf.definition() end, "Definition")
			mapper("n", "gD", function() vim.lsp.buf.declaration() end, "Declaration")
			mapper("n", "]d", function() vim.diagnostic.goto_next() end, "Next diagnostic")
			mapper("n", "[d", function() vim.diagnostic.goto_prev() end, "Prev diagnostic")
			mapper("n", "<leader>ci", function() vim.lsp.buf.implementation() end, "Implementation")
			mapper("n", "<leader>ct", function() vim.lsp.buf.type_definition() end, "Type definition")
			mapper("n", "<leader>cs", function() vim.lsp.buf.workspace_symbol() end, "Symbol")
			mapper("n", "<leader>cd", function() vim.diagnostic.open_float() end, "Diagnostic")
			mapper("n", "<leader>ca", function() vim.lsp.buf.code_action() end, "Action")
			mapper("n", "<leader>cr", function() vim.lsp.buf.references() end, "References")
			mapper("n", "<leader>cn", function() vim.lsp.buf.rename() end, "Rename")
			mapper("n", "<leader>cf", function() vim.lsp.buf.format() end, "Format")
			mapper("i", "<C-h>", function() vim.lsp.buf.signature_help() end, "Signature help")
			mapper('n', '<leader>cD', function()
				diagnostics_active = not diagnostics_active
				diagnostical(diagnostics_active)
			end, "Toggle diagnostics")
			mapper('n', '<leader>cS', function()
				signs_active = not signs_active
				if diagnostics_active then
					signwise(signs_active)
				end
			end, "Toggle signs")
		end
	},

	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
		},
		opts = {
			automatic_enable = true,
		},
	},
}
