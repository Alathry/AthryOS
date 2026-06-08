local keymap = vim.keymap
keymap.set({"v", "x"}, "<C-S-c>", '"+y', { desc = "Copy to system clipboard" })
keymap.set("n", "<C-S-v>", '"+p', { desc = "Paste after cursor" })
keymap.set({"v", "x"}, "<C-S-v>", '"+p', { desc = "Paste over selection" })
keymap.set("i", "<C-S-v>", "<C-r>+", { desc = "Paste from clipboard in insert mode" })
keymap.set("n", "<leader>e", ":Lex 30<CR>", { desc = "Toggle Explorer" }) -- مستكشف ملفات بسيط وسريع
keymap.set("n", "<leader>nh", ":nohlsearch<CR>", { desc = "Clear search highlights" })
