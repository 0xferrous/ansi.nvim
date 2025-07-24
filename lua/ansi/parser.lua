local M = {}

M.colors = {
  [30] = 'black',
  [31] = 'red',
  [32] = 'green',
  [33] = 'yellow',
  [34] = 'blue',
  [35] = 'magenta',
  [36] = 'cyan',
  [37] = 'white',
  [90] = 'bright_black',
  [91] = 'bright_red',
  [92] = 'bright_green',
  [93] = 'bright_yellow',
  [94] = 'bright_blue',
  [95] = 'bright_magenta',
  [96] = 'bright_cyan',
  [97] = 'bright_white',
}

M.bg_colors = {
  [40] = 'black',
  [41] = 'red',
  [42] = 'green',
  [43] = 'yellow',
  [44] = 'blue',
  [45] = 'magenta',
  [46] = 'cyan',
  [47] = 'white',
  [100] = 'bright_black',
  [101] = 'bright_red',
  [102] = 'bright_green',
  [103] = 'bright_yellow',
  [104] = 'bright_blue',
  [105] = 'bright_magenta',
  [106] = 'bright_cyan',
  [107] = 'bright_white',
}

function M.parse_ansi_sequence(sequence)
  local codes = {}
  for code in sequence:gmatch('%d+') do
    table.insert(codes, tonumber(code))
  end

  local attrs = {
    fg = nil,
    bg = nil,
    bold = false,
    italic = false,
    underline = false,
    reset = false,
  }

  for _, code in ipairs(codes) do
    if code == 0 then
      attrs.reset = true
    elseif code == 1 then
      attrs.bold = true
    elseif code == 3 then
      attrs.italic = true
    elseif code == 4 then
      attrs.underline = true
    elseif M.colors[code] then
      attrs.fg = M.colors[code]
    elseif M.bg_colors[code] then
      attrs.bg = M.bg_colors[code]
    end
  end

  return attrs
end

function M.find_ansi_sequences(text)
  local sequences = {}
  local start_pos = 1

  while true do
    -- Look for ESC[ followed by digits/semicolons and ending with 'm'
    local esc_start, esc_end = text:find('\27%[[%d;]*m', start_pos)
    if not esc_start then
      break
    end

    local sequence = text:sub(esc_start + 2, esc_end - 1)  -- Skip ESC and [
    local attrs = M.parse_ansi_sequence(sequence)

    table.insert(sequences, {
      start_pos = esc_start,
      end_pos = esc_end,
      sequence = sequence,
      attrs = attrs,
      full_match = text:sub(esc_start, esc_end),
    })

    start_pos = esc_end + 1
  end

  return sequences
end

return M
