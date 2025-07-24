local M = {}

M.highlight_groups = {}

local color_map = {
  black = '#000000',
  red = '#cd0000',
  green = '#00cd00',
  yellow = '#cdcd00',
  blue = '#0000ee',
  magenta = '#cd00cd',
  cyan = '#00cdcd',
  white = '#e5e5e5',
  bright_black = '#7f7f7f',
  bright_red = '#ff0000',
  bright_green = '#00ff00',
  bright_yellow = '#ffff00',
  bright_blue = '#5c5cff',
  bright_magenta = '#ff00ff',
  bright_cyan = '#00ffff',
  bright_white = '#ffffff',
}

function M.setup_highlight_groups()
  for _, fg_color in pairs(color_map) do
    for fg_name, fg_hex in pairs(color_map) do
      local group_name = 'AnsiFg' .. fg_name:gsub('_', '')
      vim.api.nvim_set_hl(0, group_name, { fg = fg_hex })
      M.highlight_groups[fg_name] = group_name
    end

    for bg_name, bg_hex in pairs(color_map) do
      local group_name = 'AnsiBg' .. bg_name:gsub('_', '')
      vim.api.nvim_set_hl(0, group_name, { bg = bg_hex })
      M.highlight_groups['bg_' .. bg_name] = group_name
    end
  end

  for fg_name, fg_hex in pairs(color_map) do
    for bg_name, bg_hex in pairs(color_map) do
      local group_name = 'AnsiFg' .. fg_name:gsub('_', '') .. 'Bg' .. bg_name:gsub('_', '')
      vim.api.nvim_set_hl(0, group_name, { fg = fg_hex, bg = bg_hex })
      M.highlight_groups[fg_name .. '_bg_' .. bg_name] = group_name
    end
  end

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

  if attrs.fg then
    hl_def.fg = color_map[attrs.fg]
  end
  if attrs.bg then
    hl_def.bg = color_map[attrs.bg]
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
