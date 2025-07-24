local parser = require('ansi.parser')
local highlights = require('ansi.highlights')

local M = {}

M.namespace = vim.api.nvim_create_namespace('ansi_colors')

function M.clear_buffer_highlights(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, M.namespace, 0, -1)
end

function M.apply_ansi_highlighting(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  M.clear_buffer_highlights(bufnr)

  for line_num, line in ipairs(lines) do
    local sequences = parser.find_ansi_sequences(line)

    if #sequences > 0 then
      local current_attrs = {}
      local text_offset = 0

      for _, seq in ipairs(sequences) do
        if seq.attrs.reset then
          current_attrs = {}
        else
          for k, v in pairs(seq.attrs) do
            if k ~= 'reset' and v then
              current_attrs[k] = v
            end
          end
        end

        local start_col = seq.start_pos - 1 - text_offset
        local end_col = seq.end_pos - text_offset

        vim.api.nvim_buf_set_extmark(bufnr, M.namespace, line_num - 1, start_col, {
          end_col = end_col,
          conceal = '',
        })

        text_offset = text_offset + (seq.end_pos - seq.start_pos + 1)

        local next_seq_start = nil
        for i, next_seq in ipairs(sequences) do
          if next_seq.start_pos > seq.end_pos then
            next_seq_start = next_seq.start_pos - 1 - text_offset
            break
          end
        end

        if next_seq_start == nil then
          next_seq_start = #line - text_offset
        end

        if next_seq_start > end_col and next(current_attrs) then
          local hl_group = highlights.get_highlight_group(current_attrs)
          if not hl_group then
            hl_group = highlights.create_dynamic_highlight(current_attrs)
          end

          if hl_group then
            vim.api.nvim_buf_set_extmark(bufnr, M.namespace, line_num - 1, end_col, {
              end_col = next_seq_start,
              hl_group = hl_group,
            })
          end
        end
      end
    end
  end
end

function M.setup_syntax_matching(bufnr)
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd('syntax match AnsiEscape /\\e\\[[0-9;]*m/ conceal')
    vim.wo.conceallevel = 2
    vim.wo.concealcursor = 'nvc'
  end)
end

function M.enable_for_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  highlights.setup_highlight_groups()
  M.setup_syntax_matching(bufnr)
  M.apply_ansi_highlighting(bufnr)

  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    buffer = bufnr,
    callback = function()
      vim.defer_fn(function()
        M.apply_ansi_highlighting(bufnr)
      end, 100)
    end,
  })
end

function M.disable_for_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  M.clear_buffer_highlights(bufnr)
  vim.api.nvim_buf_call(bufnr, function()
    vim.wo.conceallevel = 0
  end)
end

return M
