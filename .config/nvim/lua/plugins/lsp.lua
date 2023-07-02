return {
	{
		'neovim/nvim-lspconfig',
		config = function()
			local diagnostics_active = true
			local virt_text = {
				severity_limit = "Warning",
			}
				vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
					vim.lsp.diagnostic.on_publish_diagnostics, {
						severity_sort = true,
						signs = {
							severity_limit = "Hint",
						},
						virtual_text = virt_text,
						underline = true,
					})

			local signs = { Error = "X", Warn = " ", Hint = " ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
			end

			local function diagnostical()
				if diagnostics_active then
					vim.diagnostic.enable()
					vim.diagnostic.show()
					-- vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
					-- vim.lsp.diagnostic.on_publish_diagnostics, {
					-- 	virtual_text = virt_text,
					-- })
				else
					vim.diagnostic.disable()
					vim.diagnostic.hide()
					-- vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
					-- vim.lsp.diagnostic.on_publish_diagnostics, {
					-- 	virtual_text = false,
					-- })
				end
			end
			diagnostical()

			local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
			local lsp_attach = function(client, bufnr)
				local opts = { buffer = bufnr, remap = false }
				vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
				vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
				vim.keymap.set("n", "<leader>cws", function() vim.lsp.buf.workspace_symbol() end, opts)
				vim.keymap.set("n", "<leader>cd", function() vim.diagnostic.open_float() end, opts)
				vim.keymap.set('n', '<leader>cD', function()
					diagnostics_active = not diagnostics_active
					diagnostical()
				end)
				vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
				vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
				vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
				vim.keymap.set("n", "<leader>crr", function() vim.lsp.buf.references() end, opts)
				vim.keymap.set("n", "<leader>crn", function() vim.lsp.buf.rename() end, opts)
				vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
			end

			local lspconfig = require('lspconfig')
			require('mason-lspconfig').setup_handlers({
				function(server_name)
					lspconfig[server_name].setup({
						on_attach = lsp_attach,
						capabilities = lsp_capabilities,
					})
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
				--
				-- Example: { "--proxy", "https://proxyserver" }
				install_args = {},
			},

			-- Controls to which degree logs are written to the log file. It's useful to set this to vim.log.levels.DEBUG when
			-- debugging issues with package installations.
			log_level = vim.log.levels.INFO,

			-- Limit for the maximum amount of packages to be installed at the same time. Once this limit is reached, any further
			-- packages that are requested to be installed will be put in a queue.
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
				"mason.providers.registry-api",
			},

			ui = {
				-- Whether to automatically check for new versions when opening the :Mason window.
				check_outdated_packages_on_open = true,

				-- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
				-- border = "none",

				-- Width of the window. Accepts:
				-- - Integer greater than 1 for fixed width.
				-- - Float in the range of 0-1 for a percentage of screen width.
				width = 0.8,

				-- Height of the window. Accepts:
				-- - Integer greater than 1 for fixed height.
				-- - Float in the range of 0-1 for a percentage of screen height.
				height = 0.9,

				icons = {
					-- The list icon to use for installed packages.
					package_installed = "◍",
					-- The list icon to use for packages that are installing, or queued for installation.
					package_pending = "◍",
					-- The list icon to use for packages that are not installed.
					package_uninstalled = "◍",
				},

				keymaps = {
					-- Keymap to expand a package
					toggle_package_expand = "<CR>",
					-- Keymap to install the package under the current cursor position
					install_package = "i",
					-- Keymap to reinstall/update the package under the current cursor position
					update_package = "u",
					-- Keymap to check for new version for the package under the current cursor position
					check_package_version = "c",
					-- Keymap to update all installed packages
					update_all_packages = "U",
					-- Keymap to check which installed packages are outdated
					check_outdated_packages = "C",
					-- Keymap to uninstall a package
					uninstall_package = "X",
					-- Keymap to cancel a package installation
					cancel_installation = "<C-c>",
					-- Keymap to apply language filter
					apply_language_filter = "<C-f>",
				},
			},
		},
	},
}
