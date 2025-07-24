globals = {
  "vim",
}

read_globals = {
  "vim.api",
  "vim.cmd",
  "vim.fn",
  "vim.g",
  "vim.o",
  "vim.wo",
  "vim.bo",
  "vim.opt",
  "vim.defer_fn",
  "vim.tbl_deep_extend",
}

ignore = {
  "212", -- Unused argument
  "213", -- Unused loop variable
}

exclude_files = {
  "tests/",
}