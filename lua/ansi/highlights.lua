local themes = require('ansi.themes')

local M = {}

M.highlight_groups = {}
M.current_theme = nil

function M.setup_highlight_groups(theme_name)
  -- Clear existing highlight groups
  M.highlight_groups = {}
  
  -- Get color map based on theme
  local color_map
  if theme_name == 'terminal' then
    -- Try to use terminal's actual colors
    color_map = themes.get_terminal_colors()
    if not color_map then
      -- Fallback to modern if terminal colors not available
      color_map = themes.modern
    end
  elseif themes[theme_name] then
    color_map = themes[theme_name]
  else
    -- Default to modern theme
    color_map = themes.modern
  end
  
  M.current_theme = color_map
  
  -- Create foreground highlight groups
  for fg_name, fg_hex in pairs(color_map) do
    local group_name = 'AnsiFg' .. fg_name:gsub('_', '')
    vim.api.nvim_set_hl(0, group_name, { fg = fg_hex })
    M.highlight_groups[fg_name] = group_name
  end

  -- Create background highlight groups
  for bg_name, bg_hex in pairs(color_map) do
    local group_name = 'AnsiBg' .. bg_name:gsub('_', '')
    vim.api.nvim_set_hl(0, group_name, { bg = bg_hex })
    M.highlight_groups['bg_' .. bg_name] = group_name
  end

  -- Create combined fg/bg highlight groups
  for fg_name, fg_hex in pairs(color_map) do
    for bg_name, bg_hex in pairs(color_map) do
      local group_name = 'AnsiFg' .. fg_name:gsub('_', '') .. 'Bg' .. bg_name:gsub('_', '')
      vim.api.nvim_set_hl(0, group_name, { fg = fg_hex, bg = bg_hex })
      M.highlight_groups[fg_name .. '_bg_' .. bg_name] = group_name
    end
  end

  -- Text attribute groups
  vim.api.nvim_set_hl(0, 'AnsiBold', { bold = true })
  vim.api.nvim_set_hl(0, 'AnsiItalic', { italic = true })
  vim.api.nvim_set_hl(0, 'AnsiUnderline', { underline = true })
end

function M.get_highlight_group(attrs)
  if attrs.fg and attrs.bg then
    return M.highlight_groups[attrs.fg .. '_bg_' .. attrs.bg]
  elseif attrs.fg then
    return M.highlight_groups[attrs.fg]
  elseif attrs.bg then
    return M.highlight_groups['bg_' .. attrs.bg]
  end

  return nil
end

function M.create_dynamic_highlight(attrs)
  local hl_def = {}

  if attrs.fg and M.current_theme then
    hl_def.fg = M.current_theme[attrs.fg]
  end
  if attrs.bg and M.current_theme then
    hl_def.bg = M.current_theme[attrs.bg]
  end
  if attrs.bold then
    hl_def.bold = true
  end
  if attrs.italic then
    hl_def.italic = true
  end
  if attrs.underline then
    hl_def.underline = true
  end

  local group_name = 'AnsiDynamic' .. math.random(10000, 99999)
  vim.api.nvim_set_hl(0, group_name, hl_def)

  return group_name
end

return M
