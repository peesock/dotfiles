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
					vim.diagnostic.disable()
					vim.diagnostic.hide()
				end
			end
			diagnostical(diagnostics_active)

			-- local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
			local lsp_attach = function(client, bufnr)
				local opts = {
					buffer = bufnr,
					remap = false,
				}

				mapper("n", "K", function() vim.lsp.buf.hover() end, "", opts)
				mapper("n", "gd", function() vim.lsp.buf.definition() end, "Definition", opts)
				mapper("n", "gD", function() vim.lsp.buf.declaration() end, "Declaration", opts)
				mapper("n", "]d", function() vim.diagnostic.goto_next() end, "Next diagnostic", opts)
				mapper("n", "[d", function() vim.diagnostic.goto_prev() end, "Prev diagnostic", opts)
				mapper("n", "<leader>ci", function() vim.lsp.buf.implementation() end, "Implementation", opts)
				mapper("n", "<leader>ct", function() vim.lsp.buf.type_definition() end, "Type definition", opts)
				mapper("n", "<leader>cs", function() vim.lsp.buf.workspace_symbol() end, "Symbol", opts)
				mapper("n", "<leader>cd", function() vim.diagnostic.open_float() end, "Diagnostic", opts)
				mapper("n", "<leader>ca", function() vim.lsp.buf.code_action() end, "Action", opts)
				mapper("n", "<leader>cr", function() vim.lsp.buf.references() end, "References", opts)
				mapper("n", "<leader>cn", function() vim.lsp.buf.rename() end, "Rename", opts)
				mapper("n", "<leader>cf", function() vim.lsp.buf.format() end, "Format", opts)
				mapper("i", "<C-h>", function() vim.lsp.buf.signature_help() end, "Signature help", opts)
				mapper('n', '<leader>cD', function()
					diagnostics_active = not diagnostics_active
					diagnostical(diagnostics_active)
				end, "Toggle diagnostics", opts)
				mapper('n', '<leader>cS', function()
					signs_active = not signs_active
					if diagnostics_active then
						signwise(signs_active)
					end
				end, "Toggle signs", opts)
			end

			local lspconfig = require('lspconfig')
			require('mason-lspconfig').setup_handlers({
				function(server_name)
					local config = {
						on_attach = lsp_attach,
						-- capabilities = lsp_capabilities,
					}
					lspconfig[server_name].setup(config)
				end,
			})
		end,
	},

	{
		"williamboman/mason.nvim",
		-- enabled = false,
		dependencies = {
			{ "williamboman/mason-lspconfig.nvim" },
		},
		opts = {
			-- The directory in which to install packages.
			install_root_dir = os.getenv("HOME") .. "/.local/share/nvim/site/mason",

			-- Where Mason should put its bin location in your PATH. Can be one of:
			-- - "prepend" (default, Mason's bin location is put first in PATH)
			-- - "append" (Mason's bin location is put at the end of PATH)
			-- - "skip" (doesn't modify PATH)
			---@type '"prepend"' | '"append"' | '"skip"'
			PATH = "prepend",

			pip = {
				-- Whether to upgrade pip to the latest version in the virtual environment before installing packages.
				upgrade_pip = false,
				-- These args will be added to `pip install` calls. Note that setting extra args might impact intended behavior
				-- and is not recommended.
				-- Example: { "--proxy", "https://proxyserver" }
				install_args = {},
			},

			-- Controls to which degree logs are written to the log file.
			log_level = vim.log.levels.INFO,

			max_concurrent_installers = 4,

			github = {
				-- The template URL to use when downloading assets from GitHub.
				-- The placeholders are the following (in order):
				-- 1. The repository (e.g. "rust-lang/rust-analyzer")
				-- 2. The release version (e.g. "v0.3.0")
				-- 3. The asset name (e.g. "rust-analyzer-v0.3.0-x86_64-unknown-linux-gnu.tar.gz")
				download_url_template = "https://github.com/%s/releases/download/%s/%s",
			},

			-- The provider implementations to use for resolving package metadata (latest version, available versions, etc.).
			-- Accepts multiple entries, where later entries will be used as fallback should prior providers fail.
			-- Builtin providers are:
			--   - mason.providers.registry-api (default) - uses the https://api.mason-registry.dev API
			--   - mason.providers.client                 - uses only client-side tooling to resolve metadata
			providers = {
				"mason.providers.client",
			},

			ui = {
				-- Whether to automatically check for new versions when opening the :Mason window.
				check_outdated_packages_on_open = true,

				-- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
				-- border = "none",

				width = 0.8,
				height = 0.9,

				icons = {
					package_installed = "◍",
					package_pending = "◍",
					package_uninstalled = "◍",
				},

				keymaps = {
					toggle_package_expand = "<CR>",
					install_package = "i",
					update_package = "u",
					check_package_version = "c",
					update_all_packages = "U",
					check_outdated_packages = "C",
					uninstall_package = "X",
					cancel_installation = "<C-c>",
					apply_language_filter = "<C-f>",
				},
			},
		},
	},
}
