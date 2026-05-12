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
vim.lsp.config['ts_ls'] = {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
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

vim.lsp.enable({ 'ts_ls', 'lua_ls', 'dockerls', 'yamlls', 'taplo' })

-- Completion & inlay hints
vim.opt.completeopt = { 'menuone', 'popup' }
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
      if client:supports_method('textDocument/inlayHint') then
        vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
      end
    end
  end,
})
