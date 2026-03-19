if vim.g.loaded_knapping then
  return
end

vim.g.loaded_knapping = 1

require("knapping").setup()
