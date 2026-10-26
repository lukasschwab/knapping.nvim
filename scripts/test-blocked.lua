-- Run from the repository root:
-- nvim --headless -u NONE -i NONE --cmd 'set rtp+=.' -l scripts/test-blocked.lua
local function test()
  local knapping = require("knapping")
  local bufnr = vim.api.nvim_get_current_buf()
  vim.bo[bufnr].filetype = "markdown"
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
    "# Checkboxes",
    "- [B] blocked",
    "  - [B] nested blocked",
    "> - [B] quoted blocked",
    "1. [B] numbered blocked",
    "- [b] bookmark",
    "Plain [B] is not a task",
  })
  local namespace = vim.api.nvim_create_namespace("knapping")
  local function marks()
    return vim.api.nvim_buf_get_extmarks(bufnr, namespace, 0, -1, { details = true })
  end

  for background, color in pairs({ light = 0xb44a3a, dark = 0xd16b5b }) do
    vim.o.background = background
    knapping.setup()
    assert(vim.api.nvim_get_hl(0, { name = "KnappingCheckboxblocked" }).fg == color)
    local extmarks = marks()
    assert(#extmarks == 5, "Only list checkboxes should be highlighted")
    for i = 1, 4 do
      local mark = extmarks[i]
      local line = vim.api.nvim_buf_get_lines(bufnr, mark[2], mark[2] + 1, false)[1]
      assert(line:sub(mark[3] + 1, mark[4].end_col) == "[B]")
      assert(mark[4].hl_group == "KnappingCheckboxblocked")
      assert(not mark[4].virt_text, "ASCII mode should not overlay symbols")
    end
    assert(extmarks[5][4].hl_group == "KnappingCheckboxbookmark")
  end

  knapping.setup({ use_nerd_font = true })
  assert(marks()[1][4].virt_text[1][1] == "  ")
  assert(marks()[1][4].virt_text[1][2] == "KnappingCheckboxblocked")
  vim.api.nvim_win_set_cursor(0, { 2, 0 })
  vim.api.nvim_exec_autocmds("CursorMoved", { buffer = bufnr })
  assert(not marks()[1][4].virt_text, "Reveal [B] on the cursor line")
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  vim.api.nvim_exec_autocmds("CursorMoved", { buffer = bufnr })
  assert(marks()[1][4].virt_text[1][1] == "  ")

  knapping.setup({
    use_nerd_font = true,
    palette = { dark = { rust = "#abcdef" } },
    symbols = { blocked = "!" },
  })
  vim.o.background = "dark"
  knapping.refresh()
  assert(vim.api.nvim_get_hl(0, { name = "KnappingCheckboxblocked" }).fg == 0xabcdef)
  assert(marks()[1][4].virt_text[1][1] == "!  ")
end

local ok, err = pcall(test)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
end
print("Blocked checkbox tests passed")
vim.cmd("qa!")
