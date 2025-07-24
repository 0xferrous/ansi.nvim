if vim.g.loaded_ansi then
  return
end
vim.g.loaded_ansi = 1

vim.api.nvim_create_user_command('AnsiEnable', function(opts)
  local bufnr = opts.args ~= '' and tonumber(opts.args) or nil
  require('ansi').enable(bufnr)
end, {
  nargs = '?',
  desc = 'Enable ANSI color rendering for buffer'
})

vim.api.nvim_create_user_command('AnsiDisable', function(opts)
  local bufnr = opts.args ~= '' and tonumber(opts.args) or nil
  require('ansi').disable(bufnr)
end, {
  nargs = '?',
  desc = 'Disable ANSI color rendering for buffer'
})

vim.api.nvim_create_user_command('AnsiToggle', function(opts)
  local bufnr = opts.args ~= '' and tonumber(opts.args) or nil
  require('ansi').toggle(bufnr)
end, {
  nargs = '?',
  desc = 'Toggle ANSI color rendering for buffer'
})