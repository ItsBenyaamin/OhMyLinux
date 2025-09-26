local map = vim.keymap.set

-- Set leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Disable the spacebar key's default behavior in Normal and Visual modes
map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- For conciseness
local opts = { noremap = true, silent = true }

-- Select all
map('n', '<C-a>', 'gg<S-v>G', { desc = 'Select all', noremap = true })

-- Indenting
map('v', '<', '<gv', { desc = 'Indenting', silent = true, noremap = true })
map('v', '>', '>gv', { desc = 'Indenting', silent = true, noremap = true })

-- Increment/decrement
map('n', '+', '<C-a>', { desc = 'Increment numbers', noremap = true })
map('n', '-', '<C-x>', { desc = 'Decrement numbers', noremap = true })

-- save file
map('n', '<C-s>', '<cmd> w <CR>', opts)

-- save file without auto-formatting
map('n', '<leader>sn', '<cmd>noautocmd w <CR>', opts)

-- quit file
map('n', '<C-q>', '<cmd> q <CR>', opts)

-- delete single character without copying into register
map('n', 'x', '"_x', opts)

-- Vertical scroll and center
map('n', '<C-d>', '<C-d>zz', opts)
map('n', '<C-u>', '<C-u>zz', opts)

-- Find and center
map('n', 'n', 'nzzzv', opts)
map('n', 'N', 'Nzzzv', opts)

-- Resize with arrows
map('n', '<S-Up>', ':resize -2<CR>', opts)
map('n', '<S-Down>', ':resize +2<CR>', opts)
map('n', '<S-Left>', ':vertical resize -2<CR>', opts)
map('n', '<S-Right>', ':vertical resize +2<CR>', opts)

-- Buffers
map('n', '<Tab>', ':bnext<CR>', opts)
map('n', '<S-Tab>', ':bprevious<CR>', opts)
map('n', '<leader>x', ':bdelete!<CR>', opts) -- close buffer
map('n', '<leader>b', '<cmd> enew <CR>', opts) -- new buffer

-- Window management
map('n', '<leader>v', '<C-w>v', opts) -- split window vertically
map('n', '<leader>h', '<C-w>s', opts) -- split window horizontally
map('n', '<leader>se', '<C-w>=', opts) -- make split windows equal width & height
map('n', '<leader>xs', ':close<CR>', opts) -- close current split window

-- Navigate between splits
map('n', '<C-k>', ':wincmd k<CR>', opts)
map('n', '<C-j>', ':wincmd j<CR>', opts)
map('n', '<C-h>', ':wincmd h<CR>', opts)
map('n', '<C-l>', ':wincmd l<CR>', opts)

-- Tabs
map('n', '<leader>to', ':tabnew<CR>', opts) -- open new tab
map('n', '<leader>tx', ':tabclose<CR>', opts) -- close current tab
map('n', '<leader>tn', ':tabn<CR>', opts) --  go to next tab
map('n', '<leader>tp', ':tabp<CR>', opts) --  go to previous tab

-- Toggle line wrapping
map('n', '<leader>lw', '<cmd>set wrap!<CR>', opts)

-- Stay in indent mode
map('v', '<', '<gv', opts)
map('v', '>', '>gv', opts)

-- Keep last yanked when pasting
map('v', 'p', '"_dP', opts)

-- Diagnostic keymaps
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
map('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
