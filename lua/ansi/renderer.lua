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
      -- First pass: conceal all ANSI sequences
      for _, seq in ipairs(sequences) do
        vim.api.nvim_buf_set_extmark(bufnr, M.namespace, line_num - 1, seq.start_pos - 1, {
          end_col = seq.end_pos,
          conceal = '',
        })
      end

      -- Second pass: apply colors to text segments
      local current_attrs = {}
      local last_pos = 1

      for i, seq in ipairs(sequences) do
        -- Apply highlighting to text before this sequence
        if seq.start_pos > last_pos and next(current_attrs) then
          local hl_group = highlights.get_highlight_group(current_attrs)
          if not hl_group then
            hl_group = highlights.create_dynamic_highlight(current_attrs)
          end

          if hl_group then
            vim.api.nvim_buf_set_extmark(bufnr, M.namespace, line_num - 1, last_pos - 1, {
              end_col = seq.start_pos - 1,
              hl_group = hl_group,
            })
          end
        end

        -- Update current attributes
        if seq.attrs.reset then
          current_attrs = {}
        else
          for k, v in pairs(seq.attrs) do
            if k ~= 'reset' and v then
              current_attrs[k] = v
            end
          end
        end

        last_pos = seq.end_pos + 1
      end

      -- Apply highlighting to remaining text after last sequence
      if last_pos <= #line and next(current_attrs) then
        local hl_group = highlights.get_highlight_group(current_attrs)
        if not hl_group then
          hl_group = highlights.create_dynamic_highlight(current_attrs)
        end

        if hl_group then
          vim.api.nvim_buf_set_extmark(bufnr, M.namespace, line_num - 1, last_pos - 1, {
            end_col = #line,
            hl_group = hl_group,
          })
        end
      end
    end
  end
end

function M.setup_syntax_matching(bufnr)
  vim.api.nvim_buf_call(bufnr, function()
    -- Clear existing syntax
    vim.cmd('syntax clear')

    -- Set concealment options
    vim.wo.conceallevel = 2
    vim.wo.concealcursor = 'nvc'

    -- We handle concealment via extmarks, not syntax
  end)
end

-- Custom fold text function that strips ANSI sequences
function M.clean_fold_text()
  local line = vim.fn.getline(vim.v.foldstart)
  -- Remove ANSI escape sequences from fold text
  local clean_line = line:gsub('\27%[[%d;]*m', '')
  local line_count = vim.v.foldend - vim.v.foldstart + 1
  return clean_line .. ' (' .. line_count .. ' lines)'
end

function M.setup_fold_handling(bufnr)
  vim.api.nvim_buf_call(bufnr, function()
    -- Only set custom fold text if no fold plugin is already active
    local current_foldtext = vim.wo.foldtext
    if current_foldtext == '' or current_foldtext == 'foldtext()' then
      -- Set custom fold text function to strip ANSI codes
      vim.wo.foldtext = 'v:lua.require("ansi.renderer").clean_fold_text()'
    else
      -- If another fold plugin is active, we'll use a different approach
      -- by creating an autocmd to clean fold text dynamically
      vim.api.nvim_create_autocmd('CursorMoved', {
        buffer = bufnr,
        callback = function()
          -- This is a placeholder for future fold text cleaning when other plugins are active
          -- For now, we'll just let the other plugin handle folding
        end,
        desc = 'ANSI fold text compatibility',
      })
    end
  end)
end

function M.enable_for_buffer(bufnr, theme)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  highlights.setup_highlight_groups(theme)
  M.setup_syntax_matching(bufnr)
  M.setup_fold_handling(bufnr)
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
    -- Reset fold text to default
    vim.wo.foldtext = ''
  end)
end

return M
