local M = {}

-- Classic ANSI colors (original)
M.classic = {
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

-- Modern terminal colors (like iTerm2, Windows Terminal default)
M.modern = {
  black = '#0c0c0c',
  red = '#c50f1f',
  green = '#13a10e',
  yellow = '#c19c00',
  blue = '#0037da',
  magenta = '#881798',
  cyan = '#3a96dd',
  white = '#cccccc',
  bright_black = '#767676',
  bright_red = '#e74856',
  bright_green = '#16c60c',
  bright_yellow = '#f9f1a5',
  bright_blue = '#3b78ff',
  bright_magenta = '#b4009e',
  bright_cyan = '#61d6d6',
  bright_white = '#f2f2f2',
}

-- Catppuccin-like colors (modern, soft)
M.catppuccin = {
  black = '#1e1e2e',
  red = '#f38ba8',
  green = '#a6e3a1',
  yellow = '#f9e2af',
  blue = '#89b4fa',
  magenta = '#f5c2e7',
  cyan = '#94e2d5',
  white = '#cdd6f4',
  bright_black = '#45475a',
  bright_red = '#f38ba8',
  bright_green = '#a6e3a1',
  bright_yellow = '#f9e2af',
  bright_blue = '#89b4fa',
  bright_magenta = '#f5c2e7',
  bright_cyan = '#94e2d5',
  bright_white = '#bac2de',
}

-- Dracula theme colors
M.dracula = {
  black = '#21222c',
  red = '#ff5555',
  green = '#50fa7b',
  yellow = '#f1fa8c',
  blue = '#6272a4',
  magenta = '#ff79c6',
  cyan = '#8be9fd',
  white = '#f8f8f2',
  bright_black = '#44475a',
  bright_red = '#ff6e6e',
  bright_green = '#69ff94',
  bright_yellow = '#ffffa5',
  bright_blue = '#d6acff',
  bright_magenta = '#ff92df',
  bright_cyan = '#a4ffff',
  bright_white = '#ffffff',
}

-- One Dark colors
M.onedark = {
  black = '#282c34',
  red = '#e06c75',
  green = '#98c379',
  yellow = '#e5c07b',
  blue = '#61afef',
  magenta = '#c678dd',
  cyan = '#56b6c2',
  white = '#abb2bf',
  bright_black = '#5c6370',
  bright_red = '#e06c75',
  bright_green = '#98c379',
  bright_yellow = '#e5c07b',
  bright_blue = '#61afef',
  bright_magenta = '#c678dd',
  bright_cyan = '#56b6c2',
  bright_white = '#ffffff',
}

-- Gruvbox Dark colors (the ones used by bat and most terminals)
M.gruvbox = {
  black = '#282828', -- bg0
  red = '#cc241d', -- neutral_red
  green = '#98971a', -- neutral_green
  yellow = '#d79921', -- neutral_yellow
  blue = '#458588', -- neutral_blue
  magenta = '#b16286', -- neutral_purple
  cyan = '#689d6a', -- neutral_aqua
  white = '#a89984', -- fg4
  bright_black = '#928374', -- gray
  bright_red = '#fb4934', -- bright_red
  bright_green = '#b8bb26', -- bright_green
  bright_yellow = '#fabd2f', -- bright_yellow
  bright_blue = '#83a598', -- bright_blue
  bright_magenta = '#d3869b', -- bright_purple
  bright_cyan = '#8ec07c', -- bright_aqua
  bright_white = '#ebdbb2', -- fg0
}

-- Gruvbox Dark is the same as gruvbox
M.gruvbox_dark = M.gruvbox

-- Gruvbox Light colors
M.gruvbox_light = {
  black = '#fbf1c7', -- bg0 (light)
  red = '#cc241d', -- neutral_red (same)
  green = '#98971a', -- neutral_green (same)
  yellow = '#d79921', -- neutral_yellow (same)
  blue = '#458588', -- neutral_blue (same)
  magenta = '#b16286', -- neutral_purple (same)
  cyan = '#689d6a', -- neutral_aqua (same)
  white = '#7c6f64', -- fg4 (dark on light)
  bright_black = '#928374', -- gray (same)
  bright_red = '#9d0006', -- bright_red (darker for light bg)
  bright_green = '#79740e', -- bright_green (darker for light bg)
  bright_yellow = '#b57614', -- bright_yellow (darker for light bg)
  bright_blue = '#076678', -- bright_blue (darker for light bg)
  bright_magenta = '#8f3f71', -- bright_purple (darker for light bg)
  bright_cyan = '#427b58', -- bright_aqua (darker for light bg)
  bright_white = '#3c3836', -- fg0 (darkest on light)
}

-- Get terminal's actual colors if possible
function M.get_terminal_colors()
  local colors = {}

  -- Try to read from terminal
  for i = 0, 15 do
    local hl = vim.api.nvim_get_hl(0, { name = string.format('Terminal%d', i) })
    if hl.fg then
      local color_name = ({
        [0] = 'black',
        [1] = 'red',
        [2] = 'green',
        [3] = 'yellow',
        [4] = 'blue',
        [5] = 'magenta',
        [6] = 'cyan',
        [7] = 'white',
        [8] = 'bright_black',
        [9] = 'bright_red',
        [10] = 'bright_green',
        [11] = 'bright_yellow',
        [12] = 'bright_blue',
        [13] = 'bright_magenta',
        [14] = 'bright_cyan',
        [15] = 'bright_white',
      })[i]

      if color_name then
        colors[color_name] = string.format('#%06x', hl.fg)
      end
    end
  end

  -- Return colors if we got all 16, otherwise return nil
  local count = 0
  for _, _ in pairs(colors) do
    count = count + 1
  end

  return count == 16 and colors or nil
end

return M
