vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.clipboard = 'unnamedplus'

vim.o.number = true
-- vim.o.relativenumber = true

vim.o.signcolumn = 'yes'

vim.o.tabstop = 4
vim.o.shiftwidth = 4

vim.o.updatetime = 300

vim.o.termguicolors = true

vim.o.mouse = 'a'

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        vim.opt.formatoptions:remove({ "c", "r", "o" })
    end,
})

vim.keymap.set("n", "<Up>", "gk", { noremap = true, silent = true })
vim.keymap.set("n", "<Down>", "gj", { noremap = true, silent = true })
vim.keymap.set("v", "<Up>", "gk", { noremap = true, silent = true })
vim.keymap.set("v", "<Down>", "gj", { noremap = true, silent = true })
vim.keymap.set("i", "<Up>", "<C-o>gk", { noremap = true, silent = true })
vim.keymap.set("i", "<Down>", "<C-o>gj", { noremap = true, silent = true })

vim.opt.undofile = true
