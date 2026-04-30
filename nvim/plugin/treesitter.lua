-- nvim-treesitter.configs is deprecated and removed in recent versions.
-- Highlighting and indentation are now handled by Neovim's native APIs.

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local ft = vim.bo[bufnr].filetype
    local lang = vim.treesitter.language.get_lang(ft)

    if lang and lang ~= "" then
      -- Start Treesitter highlighting for the current buffer
      pcall(vim.treesitter.start, bufnr, lang)

      -- Enable Treesitter-based indentation
      vim.bo[bufnr].indentexpr = "v:lua.vim.treesitter.indentexpr()"
    end
  end,
})

-- Optional: Enable folding using Treesitter
--vim.api.nvim_create_autocmd("FileType", {
--  group = vim.api.nvim_create_augroup("TreesitterFolding", { clear = true }),
--  callback = function(args)
--    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
--    if lang and lang ~= "" then
--      vim.wo[0].foldmethod = "expr"
--      vim.wo[0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
--    end
--  end,
--})
