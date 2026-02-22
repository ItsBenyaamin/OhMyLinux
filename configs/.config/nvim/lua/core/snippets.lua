-- Custom code snippets for different purposes

-- Prevent LSP from overwriting treesitter color settings
-- https://github.com/NvChad/NvChad/issues/1907
vim.hl.priorities.semantic_tokens = 95 -- Or any number lower than 100, treesitter's priority level

-- Appearance of diagnostics
vim.diagnostic.config {
  virtual_text = {
    prefix = '●',
    -- Add a custom format function to show error codes
    format = function(diagnostic)
      local code = diagnostic.code and string.format('[%s]', diagnostic.code) or ''
      return string.format('%s %s', code, diagnostic.message)
    end,
  },
  severity_sort = true,
  underline = false,
  update_in_insert = true,
  float = { border = 'rounded', source = 'if_many' },
  -- Make diagnostic background transparent
  on_ready = function()
    vim.cmd 'highlight DiagnosticVirtualText guibg=NONE'
  end,
}

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Close Buffer with <S + q>
vim.keymap.set('n', '<leader>q', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if not bufname:match 'neo%-tree' then
    vim.cmd 'bprevious'
    vim.cmd('bdelete' .. bufnr)
  end
end, { desc = 'Close buffer safely' })

vim.api.nvim_create_autocmd('ModeChanged', {
  callback = function(event)
    local new_mode = event.match:match ':(.*)$'
    if new_mode == 'i' then
      os.execute 'bash $HOME/.config/helpers/toggletrackpad.sh disable > /dev/null'
    else
      os.execute 'bash $HOME/.config/helpers/toggletrackpad.sh enable > /dev/null'
    end
  end,
})
