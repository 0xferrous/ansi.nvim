# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is ansi.nvim, a Neovim plugin that renders ANSI color escape codes as actual colors in buffers using concealer.

## Architecture

The plugin is structured in modular components:

- `lua/ansi/parser.lua` - Parses ANSI escape sequences and extracts color/style attributes
- `lua/ansi/highlights.lua` - Manages highlight groups and color mappings
- `lua/ansi/renderer.lua` - Handles buffer highlighting using extmarks and concealer
- `lua/ansi/init.lua` - Main plugin interface and configuration
- `plugin/ansi.lua` - Plugin initialization and user commands

## Key Implementation Details

- Uses `vim.api.nvim_buf_set_extmark()` with `conceal` option to hide ANSI sequences
- Creates dynamic highlight groups for color combinations
- Uses autocmds to update highlighting on text changes
- Supports standard and bright ANSI colors plus text attributes (bold, italic, underline)

## Common Commands

- Test the plugin: `:AnsiEnable` then paste ANSI-colored text
- For Lua linting: Use `luacheck` if available
- For testing: Consider `plenary.nvim` test framework

## Development Notes

- The concealer approach hides escape sequences while preserving text positioning
- Extmarks are used for both concealing sequences and applying highlights
- Color parsing supports codes 30-37, 40-47, 90-97, 100-107 plus attributes 0,1,3,4

## Development Workflow

- Always run the linting, testing, and style check CI locally with `act` or directly before considering a task finished