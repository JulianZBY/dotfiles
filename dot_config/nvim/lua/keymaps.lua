-- stylua: ignore start

vim.keymap.set({ "n", "x", "o" }, "<CR>", function() require("flash").jump() end, { silent = true, desc = "Flash: 搜索跳转" })
vim.keymap.set({ "n", "x", "o" }, "<S-CR>", function() require("flash").treesitter() end, { silent = true, desc = "Flash: Treesitter 跳转" })

vim.keymap.set({ "x", "o" }, "af", function() require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects") end, { desc = "选函数" })
vim.keymap.set({ "x", "o" }, "if", function() require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects") end, { desc = "函数体" })
vim.keymap.set({ "x", "o" }, "ac", function() require("nvim-treesitter-textobjects.select").select_textobject("@comment.outer", "textobjects") end, { desc = "注释" })

vim.keymap.set("n", "<leader>e", function() require("yazi").yazi()end, { silent = true, desc = "Open yazi" })

require("mini.keymap").map_multistep("i", "<Tab>", { "increase_indent", "jump_after_tsnode", "jump_after_close" })
require("mini.keymap").map_multistep("i", "<S-Tab>", { "decrease_indent", "jump_before_tsnode", "jump_before_open" })

-- stylua: ignore end
