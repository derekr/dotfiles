vim.g.mapleader = ' '

vim.pack.add({
  { src = 'https://github.com/folke/flash.nvim' },
  { src = 'https://github.com/nvim-mini/mini.files' },
  { src = 'https://github.com/nvim-mini/mini.pick' },
  { src = 'https://github.com/nvim-mini/mini.extra' },
})

local flash = require('flash')
vim.keymap.set({ 'n', 'x', 'o' }, 's', flash.jump, { desc = 'Flash' })
vim.keymap.set({ 'n', 'x', 'o' }, 'S', flash.treesitter, { desc = 'Flash Treesitter' })
vim.keymap.set('o', 'r', flash.remote, { desc = 'Remote Flash' })
vim.keymap.set({ 'o', 'x' }, 'R', flash.treesitter_search, { desc = 'Treesitter Search' })
vim.keymap.set('c', '<C-s>', flash.toggle, { desc = 'Toggle Flash Search' })

require('mini.files').setup()
vim.keymap.set('n', '<leader>e', function() require('mini.files').open(vim.api.nvim_buf_get_name(0)) end, { desc = 'Open file explorer' })

require('mini.pick').setup()
require('mini.extra').setup()
local function pick(fn)
  return function()
    MiniFiles.close()
    fn()
  end
end
vim.keymap.set('n', '<leader>f', pick(MiniPick.builtin.files), { desc = 'Find files' })
vim.keymap.set('n', '<leader>g', pick(MiniPick.builtin.grep_live), { desc = 'Live grep' })
vim.keymap.set('n', '<leader>b', pick(MiniPick.builtin.buffers), { desc = 'Buffers' })
vim.keymap.set('n', '<leader>h', pick(MiniPick.builtin.help), { desc = 'Help' })
vim.keymap.set('n', '<leader>/', MiniExtra.pickers.history, { desc = 'Search history' })

-- LSP

-- TypeScript / JavaScript — native TS 7 server (typescript-go).
-- `typescript@7` is the Go port: it ships no tsserver.js, so the classic
-- `typescript-language-server` is dead here. The native binary embeds its own
-- LSP, launched via `tsc --lsp -stdio` (mise keeps `tsc` pointed at the install).
local ts_inlay_hints = {
  parameterNames = { enabled = 'all', suppressWhenArgumentMatchesName = false },
  parameterTypes = { enabled = true },
  variableTypes = { enabled = true, suppressWhenTypeMatchesName = false },
  propertyDeclarationTypes = { enabled = true },
  functionLikeReturnTypes = { enabled = true },
  enumMemberValues = { enabled = true },
}
vim.lsp.config['tsgo'] = {
  cmd = { 'tsc', '--lsp', '-stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  settings = {
    typescript = { inlayHints = ts_inlay_hints },
    javascript = { inlayHints = ts_inlay_hints },
  },
}

vim.lsp.config['lua_ls'] = {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
    },
  },
}

vim.lsp.config['dockerls'] = {
  cmd = { 'docker-langserver', '--stdio' },
  filetypes = { 'dockerfile' },
  root_markers = { 'Dockerfile', '.git' },
}

vim.lsp.config['yamlls'] = {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml' },
  root_markers = { '.git' },
}

vim.lsp.config['taplo'] = {
  cmd = { 'taplo', 'lsp', 'stdio' },
  filetypes = { 'toml' },
  root_markers = { '.git' },
}

vim.lsp.enable({ 'tsgo', 'lua_ls', 'dockerls', 'yamlls', 'taplo' })

-- Diagnostics UI (virtual_text is off by default in 0.11+)
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { prefix = '●', spacing = 2 },
  float = { border = 'rounded', source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = 'E',
      [vim.diagnostic.severity.WARN] = 'W',
      [vim.diagnostic.severity.INFO] = 'I',
      [vim.diagnostic.severity.HINT] = 'H',
    },
  },
})

-- Completion, inlay hints & per-buffer LSP keymaps
vim.opt.completeopt = { 'menuone', 'popup', 'noselect' }
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end

    -- autotrigger completion (accept with <C-y>, next/prev with <C-n>/<C-p>)
    vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    if client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end

    local map = function(keys, fn, desc)
      vim.keymap.set('n', keys, fn, { buffer = ev.buf, desc = 'LSP: ' .. desc })
    end
    -- Note: 0.11+ ships defaults already — grn (rename), gra (code action),
    -- grr (references), gri (implementation), gO (document symbol), K (hover),
    -- <C-s> signature help (insert), [d / ]d (prev/next diagnostic).
    map('gd', vim.lsp.buf.definition, 'Go to definition')
    map('gD', vim.lsp.buf.declaration, 'Go to declaration')
    map('<leader>o', function() MiniExtra.pickers.lsp({ scope = 'document_symbol' }) end, 'Document symbols')
    map('<leader>d', vim.diagnostic.open_float, 'Line diagnostics')
    map('<leader>q', vim.diagnostic.setloclist, 'Diagnostics to loclist')
    map('<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
    end, 'Toggle inlay hints')
    if client:supports_method('textDocument/formatting') then
      map('<leader>F', function() vim.lsp.buf.format({ async = true }) end, 'Format buffer')
    end
  end,
})
