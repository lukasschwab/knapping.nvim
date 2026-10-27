-- Run from the repository root:
-- nvim --headless -u NONE -i NONE --cmd 'set rtp+=.' -l scripts/test-wrapping.lua
local function test()
  vim.cmd("filetype plugin indent on")
  vim.bo.filetype = "markdown"
  vim.bo.autoindent = true
  vim.bo.textwidth = 38
  local original = vim.bo.formatlistpat
  local original_comments = vim.bo.comments
  local options = vim.bo.formatoptions
  local knapping = require("knapping").setup()
  local applied = vim.bo.formatlistpat
  local applied_comments = vim.bo.comments
  assert(applied ~= original)
  assert(vim.bo.formatoptions == options, "Preserve formatting flags")

  local text = "Here is my line-wrapped item continuing to the next line with more words."
  local function wrap(prefix, indent, insert)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { insert and "" or prefix .. text })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    if insert then
      vim.cmd("normal! i" .. prefix .. text .. "\027")
    else
      vim.cmd("normal! gg gqG")
    end
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    assert(#lines > 1, "Expected wrapping for " .. prefix)
    for i = 2, #lines do
      assert(lines[i]:match("^%s*") == string.rep(" ", indent),
        "Wrong indent for " .. prefix .. ": " .. vim.inspect(lines))
    end
  end

  -- Every supported style, including characters special in Vim patterns.
  for _, marker in ipairs({
    " ", "x", "X", "/", "-", ">", "<", "?", "!", "*", '"', "“",
    "l", "b", "B", "i", "S", "I", "p", "O", "c", "f", "k", "w",
    "u", "d", "D", "P", "M",
  }) do
    wrap("- [" .. marker .. "] ", 6)
    wrap("- [" .. marker .. "] ", 6, true)
  end
  for _, prefix in ipairs({ "* [x] ", "+ [/] ", "1. [B] ", "12) [!] ", "  - [ ] ", "- [ ]  " }) do
    wrap(prefix, #prefix)
    wrap(prefix, #prefix, true)
  end
  wrap("- ", 2)
  wrap("* ", 2)
  wrap("+ ", 2)
  wrap("12. ", 4)
  wrap("  - ", 4)
  wrap("- [z] ", 2)
  wrap("- [xx] ", 2)
  wrap("- [ ]no-space ", 2)
  wrap("", 0)
  wrap("[ ] ", 0)

  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "> - [ ] " .. text })
  vim.cmd("normal! gggqG")
  local quoted = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local items = 0
  for _, line in ipairs(quoted) do
    if line:match("^> %- %[") then
      items = items + 1
    else
      assert(line:match("^>       %S"), "Align quoted checkbox text: " .. line)
    end
  end
  assert(items == 1)

  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "- [ ] " .. text, "- [x] " .. text })
  vim.cmd("normal! gggqG")
  items = 0
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    if line:match("^%- %[") then
      items = items + 1
    else
      assert(line:match("^      %S"), "Align adjacent checkbox text: " .. line)
    end
  end
  assert(items == 2, "Keep adjacent checkbox items separate")

  local ordinary = { "- " .. text, "* " .. text, "12. " .. text, "- [z] " .. text }
  local function format_ordinary()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, ordinary)
    vim.cmd("normal! gggqG")
    return vim.api.nvim_buf_get_lines(0, 0, -1, false)
  end
  local enabled_output = format_ordinary()
  knapping.disable()
  assert(vim.deep_equal(enabled_output, format_ordinary()), "Preserve ordinary list formatting")
  knapping.enable()

  -- The formatlistpat branch also works without Markdown's comment leaders.
  knapping.disable()
  vim.bo.comments = ""
  knapping.enable()
  wrap("-   [ ]  ", 9)
  knapping.disable()
  assert(vim.bo.comments == "")
  vim.bo.comments = original_comments
  knapping.enable()

  knapping.setup()
  knapping.enable()
  assert(vim.bo.formatlistpat == applied, "Repeated setup must not duplicate patterns")
  assert(vim.bo.comments == applied_comments, "Repeated setup must not duplicate leaders")
  knapping.disable()
  assert(vim.bo.formatlistpat == original, "Disable restores the original pattern")
  assert(vim.bo.comments == original_comments, "Disable restores comment leaders")

  local custom = [[^\s*CUSTOM:\s\+]]
  vim.bo.formatlistpat = custom
  knapping.enable()
  wrap("CUSTOM: ", 8)
  wrap("- [ ] ", 6)
  knapping.disable()
  assert(vim.bo.formatlistpat == custom, "Preserve custom list patterns")
  knapping.enable()
  vim.bo.formatlistpat = original
  knapping.disable()
  assert(vim.bo.formatlistpat == original, "Preserve subsequent user changes")

  knapping.enable()
  knapping.setup({ filetypes = { "text" } })
  assert(vim.bo.formatlistpat == original, "Restore buffers removed from configured filetypes")
  knapping.setup()
  vim.bo.filetype = "text"
  assert(vim.bo.formatlistpat == vim.go.formatlistpat, "Preserve the new filetype's pattern")
  vim.cmd("enew!")
  vim.bo.filetype = "markdown"
  vim.bo.textwidth = 38
  vim.bo.autoindent = true
  wrap("- [ ] ", 6)
end

local ok, err = pcall(test)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
end
print("Checkbox wrapping tests passed")
vim.cmd("qa!")
