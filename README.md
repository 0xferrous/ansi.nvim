# ansi.nvim

[![CI](https://github.com/your-username/ansi.nvim/workflows/CI/badge.svg)](https://github.com/your-username/ansi.nvim/actions)

A Neovim plugin that renders ANSI color escape codes as actual colors in buffers using concealer.

## Features

- Renders ANSI escape sequences as actual colors
- Uses Neovim's concealer to hide escape codes
- Supports foreground and background colors
- Supports text attributes (bold, italic, underline)
- Real-time highlighting updates as you edit
- Configurable auto-enable for specific filetypes

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'your-username/ansi.nvim',
  config = function()
    require('ansi').setup({
      auto_enable = false,  -- Auto-enable for configured filetypes
      filetypes = { 'log', 'ansi' },  -- Filetypes to auto-enable
    })
  end
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'your-username/ansi.nvim',
  config = function()
    require('ansi').setup()
  end
}
```

## Usage

### Commands

- `:AnsiEnable` - Enable ANSI color rendering for current buffer
- `:AnsiDisable` - Disable ANSI color rendering for current buffer  
- `:AnsiToggle` - Toggle ANSI color rendering for current buffer

### Lua API

```lua
local ansi = require('ansi')

-- Setup with custom config
ansi.setup({
  auto_enable = true,
  filetypes = { 'log', 'ansi', 'term' }
})

-- Manual control
ansi.enable()    -- Enable for current buffer
ansi.disable()   -- Disable for current buffer
ansi.toggle()    -- Toggle for current buffer
```

## Configuration

```lua
require('ansi').setup({
  -- Automatically enable for configured filetypes
  auto_enable = false,
  
  -- Filetypes to auto-enable when auto_enable is true
  filetypes = { 'log', 'ansi' },
})
```

## Supported ANSI Codes

### Colors
- Standard colors: black, red, green, yellow, blue, magenta, cyan, white
- Bright colors: bright_black, bright_red, etc.
- Both foreground (30-37, 90-97) and background (40-47, 100-107) colors

### Text Attributes
- Bold (1)
- Italic (3) 
- Underline (4)
- Reset (0)

## Testing

### Quick Test

1. Open the provided test file:
   ```bash
   nvim test_ansi.txt
   ```

2. Enable ANSI rendering:
   ```vim
   :AnsiEnable
   ```

3. You should see colored text with ANSI escape sequences concealed

### Generate Test Data

Use the provided script to generate ANSI output:

```bash
# Generate test output
./test_script.sh > test_output.log

# Open in Neovim
nvim test_output.log

# Enable ANSI rendering
:AnsiEnable
```

### Manual Testing

Create a buffer with ANSI codes:

```
[31mThis is red text[0m
[32;1mThis is bold green text[0m
[33;4mThis is underlined yellow text[0m
[34;42mThis is blue text on green background[0m
```

Then run `:AnsiEnable` to see the colors rendered.

## Development

### Running Tests

```bash
# Run unit tests
nvim --headless -c "luafile tests/run_tests.lua" -c "qa"

# Run linting
luacheck lua/ --globals vim

# Run style check
stylua --check lua/
```

### CI/CD

The project uses GitHub Actions for continuous integration:

- **Tests**: Runs on Neovim versions 0.8.3, 0.9.5, 0.10.0, and 0.11.3
- **Linting**: Uses luacheck for Lua code analysis
- **Style**: Uses stylua for code formatting