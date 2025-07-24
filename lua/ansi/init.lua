local renderer = require('ansi.renderer')

local M = {}

M.config = {
  auto_enable = false,
  filetypes = { 'log', 'ansi' },
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  if M.config.auto_enable then
    vim.api.nvim_create_autocmd('FileType', {
      pattern = M.config.filetypes,
      callback = function()
        M.enable()
      end,
    })
  end
end

function M.enable(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  renderer.enable_for_buffer(bufnr)
end

function M.disable(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  renderer.disable_for_buffer(bufnr)
end

function M.toggle(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local conceallevel = vim.api.nvim_buf_get_option(bufnr, 'conceallevel')

  if conceallevel > 0 then
    M.disable(bufnr)
  else
    M.enable(bufnr)
  end
end

return M
