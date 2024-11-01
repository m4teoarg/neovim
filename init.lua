---@diagnostic disable: missing-fields
local vim = vim
vim.g.mapleader = " "
local o = vim.o
o.number = true
o.signcolumn = "yes"
o.scrolloff = 5
o.sidescrolloff = 5

o.hlsearch = true
o.incsearch = true

-- o.mouse:append('a')
-- o.clipboard:append('unnamedplus')

o.tabstop = 2
o.shiftwidth = 2
o.expandtab = true
o.autoindent = true

o.ignorecase = true
o.smartcase = true

o.swapfile = false
o.autoread = true
vim.bo.autoread = true

-- opt.cursorline = true
o.termguicolors = true

-- mappings
local map = vim.keymap.set

map("n", "<C-h>", "<C-w>h", { desc = "switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "switch window right" })
map("n", "<C-j>", "<C-w>j", { desc = "switch window down" })
map("n", "<C-k>", "<C-w>k", { desc = "switch window up" })

map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })

map("n", "<C-s>", "<cmd>w<CR>", { desc = "general save file" })
map("n", "<C-q>", "<cmd>q<CR>", { desc = "general save file" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "toggle line number" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })

map("n", "<leader>fm", function()
	require("conform").format({ lsp_fallback = true })
end, { desc = "general format file" })

-- Comment
map("n", "<leader>/", "gcc", { desc = "toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "toggle comment", remap = true })

-- nvimtree
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })
map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus window" })

map(
	"n",
	"<leader>h",
	"<cmd>:lua require('nvterm.terminal').new('horizontal')<CR>",
	{ desc = "open terminal horizontal" }
)
map("n", "<leader>v", "<cmd>:lua require('nvterm.terminal').new('vertical')<CR>", { desc = "open terminal vertical " })
map("n", "<leader>f", "<cmd>:lua require('nvterm.terminal').new('float')<CR>", { desc = "open terminal float " })

map("n", "<leader>ty", "<cmd>:lua require('minty.huefy').open()<CR>", { desc = "open minty " })

-- whichkey
map("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })

map("n", "<leader>wk", function()
	vim.cmd("WhichKey " .. vim.fn.input("WhichKey: "))
end, { desc = "whichkey query lookup" })

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from the plugins directory
require("lazy").setup({

	-- Mason and LSPConfig
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_pending = " ",
						package_installed = " ",
						package_uninstalled = " ",
					},
				},
			})
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"stylua",
					"html-lsp",
					"css-lsp",
					"json-lsp",
					"isort",
					"prettier",
				},
				auto_update = false,
				run_on_start = false,
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason-lspconfig.nvim" },
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
			local on_attach = function(_, bufnr)
				local function buf_set_keymap(...)
					vim.api.nvim_buf_set_keymap(bufnr, ...)
				end
				local opts = { noremap = true, silent = true }
				buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
				buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
				-- require("cmp").on_attach(_, bufnr)
			end
			local servers = { "lua_ls", "pyright", "html", "cssls" }
			for _, lsp in ipairs(servers) do
				lspconfig[lsp].setup({
					capabilities = capabilities,
					on_attach = on_attach,
				})
			end
			local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
			end
			vim.cmd([[ 
        highlight DiagnosticSignError guifg= #ff6c6b
        highlight DiagnosticSignWarn guifg= #ECBE7B 
        highlight DiagnosticSignHint guifg= #98be65 
        highlight DiagnosticSignInfo guifg= #c678dd 
        ]])
		end,
	},
	-- conform
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					html = { "prettier" },
					css = { "prettier" },
					-- twig = { "twig" },
					python = { "isort", "black" },
				},
				formatters = {
					-- Python
					black = {
						prepend_args = {
							"--fast",
							"--line-length",
							"80",
						},
					},
				},
				format_on_save = {
					-- These options will be passed to conform.format()
					timeout_ms = 5000,
					lsp_format = "fallback",
				},
			})
			-- Formatea automáticamente al guardar
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*",
				callback = function()
					require("conform").format({ async = true })
				end,
			})
		end,
	},
	--#region
	-- none-ls.nvim
	{
		"nvimtools/none-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					-- null_ls.builtins.diagnostics.eslint,
					-- null_ls.builtins.diagnostics.htmlhint,
					null_ls.builtins.formatting.prettier.with({
						filetypes = { "html", "css", "javascript", "typescript" },
					}),
				},
			})
		end,
	},
	--#endregion
	-- Instalación de nvim-ts-autotag
	{
		"windwp/nvim-ts-autotag",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},

	--
	{
		"onsails/lspkind-nvim",
		-- Plugin para íconos
		config = function()
			require("lspkind").init()
		end,
	},
	-- nvim-cmp for autocompletion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"onsails/lspkind-nvim", -- Asegúrate de incluir este plugin
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")

			local kind_icons = {
				Namespace = "󰌗",
				Text = "󰉿",
				Method = "󰆧",
				Function = "󰆧",
				Constructor = "",
				Field = "󰜢",
				Variable = "󰀫",
				Class = "󰠱",
				Interface = "",
				Module = "",
				Property = "󰜢",
				Unit = "󰑭",
				Value = "󰎠",
				Enum = "",
				Keyword = "󰌋",
				Snippet = "",
				Color = "󰏘",
				File = "󰈚",
				Reference = "󰈇",
				Folder = "󰉋",
				EnumMember = "",
				Constant = "󰏿",
				Struct = "󰙅",
				Event = "",
				Operator = "󰆕",
				TypeParameter = "󰊄",
				Table = "",
				Object = "󰅩",
				Tag = "",
				Array = "[]",
				Boolean = "",
				Number = "",
				Null = "󰟢",
				Supermaven = "",
				String = "󰉿",
				Calendar = "",
				Watch = "󰥔",
				Package = "",
				Copilot = "",
				Codeium = "",
				TabNine = "",
				BladeNav = "",
			}

			cmp.setup({
				window = {
					completion = {
						border = "rounded",
					},
					documentation = {
						border = "rounded",
					},
				},
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = {
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.close(),
					["<CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Insert,
						select = true,
					}),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif require("luasnip").expand_or_jumpable() then
							require("luasnip").expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif require("luasnip").jumpable(-1) then
							require("luasnip").jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "path" },
					{ name = "luasnip" },
					{ name = "buffer" },
				},
				formatting = {
					format = function(entry, vim_item)
						vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
						vim_item.menu = ({
							buffer = "[Buffer]",
							nvim_lsp = "[LSP]",
							luasnip = "[Snippet]",
							path = "[Path]",
						})[entry.source.name]
						return vim_item
					end,
				},
			})
		end,
	},

	--#region
	{
		"windwp/nvim-autopairs",
		opts = {
			fast_wrap = {},
			disable_filetype = { "TelescopePrompt", "vim" },
		},
		config = function(_, opts)
			require("nvim-autopairs").setup(opts)

			-- setup cmp for autopairs
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	-- nvim-treesitter for better syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"luadoc",
					"printf",
					"vim",
					"vimdoc",
					"markdown",
					"markdown_inline",
					"html",
					"css",
					"python",
					"javascript",
					"typescript",
					"tsx",
				},
				auto_install = true,
				highlight = {
					enable = true,
				},
			})
		end,
	},
	-- nvim-tree for file navigation
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup({
				view = {
					width = 30,
					side = "left",
				},
				filters = {
					dotfiles = false,
					custom = { ".git", "node_modules", ".cache" },
				},
				renderer = {
					root_folder_label = false,
					highlight_git = true,
					indent_markers = { enable = true },
					icons = {
						glyphs = {
							default = "󰈚",
							folder = {
								default = "",
								empty = "",
								empty_open = "",
								open = "",
								symlink = "",
							},
							git = { unmerged = "" },
						},
					},
				},
			})
		end,
	},
	-- telescope.nvim for fuzzy finding
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
			require("telescope").setup({
				defaults = {
					prompt_prefix = "  ",
					selection_caret = " ",
					entry_prefix = " ",
					sorting_strategy = "ascending",
					layout_config = {
						horizontal = { prompt_position = "top", preview_width = 0.55 },
						width = 0.87,
						height = 0.80,
					},
					mappings = { n = { ["Esc"] = require("telescope.actions").close } },
				},
			})
		end,
	},
	-- catppuccin theme
	{
		"catppuccin/nvim",
		as = "catppuccin",
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
			})
			vim.cmd([[colorscheme catppuccin]])
		end,
	},
	-- {
	-- 	"navarasu/onedark.nvim",
	-- 	config = function()
	-- 		require("onedark").setup({
	-- 			style = "deep",
	-- 		})
	-- 	end,
	-- },
	-- lualine for statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons", opt = true },
		config = function()
			local custom_lsp = {
				function()
					local clients = vim.lsp.get_active_clients()
					if next(clients) == nil then
						return "No LSP"
					end
					local client_names = ""
					for _, client in pairs(clients) do
						if client_names == "" then
							client_names = client.name
						else
							client_names = client_names .. ", " .. client.name
						end
					end
					return "  " .. client_names -- Adding an icon before the LSP names
				end,
				color = { fg = "#7287fd" }, -- Customize colors here
			}

			require("lualine").setup({
				options = {
					theme = "catppuccin",
					-- theme = "onedark",
					section_separators = "",
					component_separators = "",
					globalstatus = true,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch" },
					lualine_c = {
						{ "filename", file_status = true },
						{
							"diagnostics",
							sources = { "nvim_lsp" },
							symbols = {
								error = " ", -- Icon for errors
								warn = " ", -- Icon for warnings
								info = " ", -- Icon for info
								hint = " ", -- Icon for hints
							},
							diagnostics_color = {
								error = { fg = "#ff6c6b" },
								warn = { fg = "#ecd07b" },
								info = { fg = "#7abe64" },
								hint = { fg = "#dc789f" },
							},
						},
						-- custom_lsp, -- Add custom LSP module here
					},
					lualine_x = {
						custom_lsp,
						"filetype",
					},
					lualine_y = {},
					lualine_z = { "location", "progress" }, -- Moved progress and location to the rightmost section
				},
			})
		end,
	},
	--#region NvChad/nvterm
	{
		"NvChad/nvterm",
		config = function()
			require("nvterm").setup({
				terminals = {
					type_opts = {
						float = {
							relative = "editor",
							row = 0.1,
							col = 0.1,
							width = 0.8,
							height = 0.8,
							border = "single",
						},
						horizontal = {
							location = "rightbelow",
						},
						vertical = {
							location = "rightbelow",
						},
					},
					mappings = {
						toggle = "<leader>t", -- Cambia esto a tu mapeo preferido
					},
				},
			})
		end,
	},
	--#endregion
	--#region iamcco/markdown-preview.nvim
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		-- build = 'cd app && yarn install',
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},
	--#endregion
	--#region MeanderingProgrammer/render-markdown.nvim
	{
		"MeanderingProgrammer/render-markdown.nvim",
		opts = {},
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"echasnovski/mini.icons",
		},
	},
	--#endregion
	--#region folke/noice.nvim
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			routes = {
				{
					filter = { event = "notify", find = "No information available" },
					opts = { skip = true },
				},
			},
			presets = {
				lsp_doc_border = true,
			},
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
	},
	--#endregion
	--#region NvChad/volt
	{
		"NvChad/volt",
		lazy = true,
	},
	--#endregion
	--#region nvchad/minty
	{
		"nvchad/minty",
		cmd = { "Shades", "Huefy" },
	},
	--#endregion
	--#region supermaven-inc/supermaven-nvim
	{
		"supermaven-inc/supermaven-nvim",
		config = function()
			require("supermaven-nvim").setup({
				keymaps = {
					accept_suggestion = "<Tab>",
					clear_suggestion = "<C-\\>",
					accept_word = "<C-j>",
				},
				ignore_filetypes = {
					cpp = true,
				},
				suggestion_color = "#506408",
				cterm = 244,
			})
		end,
	},
	--#endregion
	--#region brenoprata10/nvim-highlight-colors
	{
		"brenoprata10/nvim-highlight-colors",
		config = function()
			require("nvim-highlight-colors").setup({
				---Render style
				---@usage 'background'|'foreground'|'virtual'
				render = "virtual",

				---Set virtual symbol (requires render to be set to 'virtual')
				virtual_symbol = "■",

				---Set virtual symbol suffix (defaults to '')
				virtual_symbol_prefix = "",

				---Set virtual symbol suffix (defaults to ' ')
				virtual_symbol_suffix = " ",

				---Set virtual symbol position()
				---@usage 'inline'|'eol'|'eow'
				---inline mimics VS Code style
				---eol stands for `end of column` - Recommended to set `virtual_symbol_suffix = ''` when used.
				---eow stands for `end of word` - Recommended to set `virtual_symbol_prefix = ' ' and virtual_symbol_suffix = ''` when used.
				virtual_symbol_position = "inline",

				---Highlight hex colors, e.g. '#FFFFFF'
				enable_hex = true,

				---Highlight short hex colors e.g. '#fff'
				enable_short_hex = true,

				---Highlight rgb colors, e.g. 'rgb(0 0 0)'
				enable_rgb = true,

				---Highlight hsl colors, e.g. 'hsl(150deg 30% 40%)'
				enable_hsl = true,

				---Highlight CSS variables, e.g. 'var(--testing-color)'
				enable_var_usage = true,

				---Highlight named colors, e.g. 'green'
				enable_named_colors = true,

				---Highlight tailwind colors, e.g. 'bg-blue-500'
				enable_tailwind = false,

				---Set custom colors
				---Label must be properly escaped with '%' to adhere to `string.gmatch`
				--- :help string.gmatch
				custom_colors = {
					{ label = "%-%-theme%-primary%-color", color = "#0f1219" },
					{ label = "%-%-theme%-secondary%-color", color = "#5a5d64" },
				},

				-- Exclude filetypes or buftypes from highlighting e.g. 'exclude_buftypes = {'text'}'
				exclude_filetypes = {},
				exclude_buftypes = {},
			})
		end,
	},
	--#endregion
	--#region folke/which-key.nvim
	{
		"folke/which-key.nvim",
		keys = { "<leader>", "<c-w>", '"', "'", "`", "c", "v", "g" },
		cmd = "WhichKey",
		opts = function()
			return {}
		end,
	},
	--#endregion
	--#endregion ident-blackline
	{
		"lukas-reineke/indent-blankline.nvim",
		opts = {
			indent = { char = "│" },
			scope = { char = "│" },
		},
		config = function(_, opts)
			local hooks = require("ibl.hooks")
			hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
			require("ibl").setup(opts)
		end,
	},
})
