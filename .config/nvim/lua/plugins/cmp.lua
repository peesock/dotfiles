return {
	{
		"hrsh7th/nvim-cmp",
		enabled = true,
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			-- { "hrsh7th/cmp-cmdline" },
			{ "L3MON4D3/LuaSnip" },
			{ "saadparwaiz1/cmp_luasnip" },
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require('luasnip')
			local has_words_before = function()
				unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

			local aliases = {
				nvim_lsp = "lsp",
				snippy = "snippet",
			}

			cmp.setup({
				snippet = {
					-- REQUIRED - you must specify a snippet engine
					expand = function(args)
						-- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
						require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
						-- require("snippy").expand_snippet(args.body) -- For `snippy` users.
						-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
					end,
				},

				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},

				mapping = cmp.mapping.preset.insert({
					--- tab completion
					["<Tab>"] = cmp.mapping(function(fallback)
						if luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif cmp.visible() then
							cmp.select_next_item()
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if luasnip.expand_or_jumpable() then
							cmp.select_next_item()
						elseif cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<CR>"] = cmp.mapping.confirm({ select = false }),

						--- not tab completion
						-- ["<C-p>"] = cmp.select_prev_item(),
						-- ["<C-n>"] = cmp.select_next_item(),
						-- ["<C-y>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
						["<C-b>"] = cmp.mapping.scroll_docs(-4),
						["<C-f>"] = cmp.mapping.scroll_docs(4),
						["<C-Space>"] = cmp.mapping.complete(),
						-- ["<S-Tab>"] = cmp.mapping.abort(),
					}),
					sources = cmp.config.sources({
						{ name = "nvim_lsp", max_item_count = 10 },
						-- { name = "vsnip" }, -- For vsnip users.
						{ name = 'luasnip' }, -- For luasnip users.
						-- { name = 'ultisnips' }, -- For ultisnips users.
						-- { name = "snippy", max_item_count = 10 }, -- For snippy users.
						{ name = "buffer", max_item_count = 10 },
						{ name = "path", max_item_count = 10 },
					}),
				})

				-- Set configuration for specific filetype.
				cmp.setup.filetype("gitcommit", {
					sources = cmp.config.sources({
						{ name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
					}, {
						{ name = "buffer" },
					}),
				})

				-- -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
				-- cmp.setup.cmdline({ "/", "?" }, {
				-- 	mapping = cmp.mapping.preset.cmdline(),
				-- 	sources = {
				-- 		{ name = "buffer" },
				-- 	},
				-- })
				--
				-- -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
				-- cmp.setup.cmdline(":", {
				-- 	mapping = cmp.mapping.preset.cmdline(),
				-- 	sources = cmp.config.sources({
				-- 		{ name = "path" },
				-- 	}, {
				-- 		{ name = "cmdline" },
				-- 	}),
				-- })
			end,
		},

		{
			'L3MON4D3/LuaSnip',
			build = 'make install_jsregexp',
			config = function()
				-- require('luasnip').config({
				--
				-- })
			end
		}
	}
