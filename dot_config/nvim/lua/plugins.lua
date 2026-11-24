vim.pack.add({
	{ src = "https://github.com/nvim-mini/mini.nvim" },
	{ src = "https://github.com/folke/flash.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/mikavilpas/yazi.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/saghen/blink.cmp", version = "v1" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/JulianZBY/rime.nvim" },
})

require("mini.ai").setup({})
require("mini.align").setup({})
require("mini.comment").setup({})
require("mini.keymap").setup({})
require("mini.move").setup({})
require("mini.operators").setup({})
require("mini.pairs").setup({})
require("mini.snippets").setup({ snippets = { require("mini.snippets").gen_loader.from_lang() } })
require("mini.splitjoin").setup({})
require("mini.surround").setup({})
require("mini.basics").setup({ options = { extra_ui = true }, autocommands = { relnum_in_visual_mode = true } })
require("mini.bracketed").setup({})
require("mini.bufremove").setup({})
require("mini.clue").setup({
	triggers = {
		{ mode = { "n", "x" }, keys = "<Leader>" },
		{ mode = "n", keys = "[" },
		{ mode = "n", keys = "]" },
		{ mode = "i", keys = "<C-x>" },
		{ mode = { "n", "x" }, keys = "g" },
		{ mode = { "n", "x" }, keys = "'" },
		{ mode = { "n", "x" }, keys = "`" },
		{ mode = "n", keys = '"' },
		{ mode = { "i", "c" }, keys = "<C-r>" },
		{ mode = "n", keys = "<C-w>" },
		{ mode = { "n", "x" }, keys = "z" },
	},
	clues = {
		require("mini.clue").gen_clues.square_brackets(),
		require("mini.clue").gen_clues.builtin_completion(),
		require("mini.clue").gen_clues.g(),
		require("mini.clue").gen_clues.marks(),
		require("mini.clue").gen_clues.registers(),
		require("mini.clue").gen_clues.windows(),
		require("mini.clue").gen_clues.z(),
	},
})
require("mini.cmdline").setup({})
require("mini.diff").setup({})
require("mini.extra").setup({})
require("mini.git").setup({})
require("mini.input").setup({})
require("mini.misc").setup({})
require("mini.pick").setup({})
require("mini.sessions").setup({})
require("mini.visits").setup({})
require("mini.animate").setup({})
require("mini.base16").setup({ palette = require("colors") })
require("mini.cursorword").setup({})
require("mini.hipatterns").setup({})
require("mini.icons").setup({})
require("mini.indentscope").setup({})
require("mini.map").setup({})
require("mini.notify").setup({})
require("mini.starter").setup({})
require("mini.statuscolumn").setup({})
require("mini.statusline").setup({})
require("mini.tabline").setup({})
require("mini.trailspace").setup({})
require("mini.fuzzy").setup({})

require("flash").setup({})
require("oil").setup({})
require("rime").setup({})
require("yazi").setup({})

require("nvim-treesitter").install(require("lang").parsers)
vim.api.nvim_create_autocmd("FileType", {
	pattern = require("lang").parsers,
	callback = function()
		vim.treesitter.start()
	end,
})

require("nvim-treesitter-textobjects").setup({ select = { lookahead = true } })

require("blink.cmp").setup({
	keymap = { preset = "enter" },
	snippets = { preset = "mini_snippets" },
	fuzzy = { prebuilt_binaries = { force_version = "v*" } },
	completion = { documentation = { auto_show = true } },
})

vim.lsp.enable(require("lang").servers)

require("conform").setup({
	formatters_by_ft = require("lang").formatters,
	format_on_save = true,
})
