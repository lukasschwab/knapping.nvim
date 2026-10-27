-- nvim --headless -u NONE -i NONE --cmd 'set rtp+=.' -l scripts/test-indentation.lua
local function test()
  vim.cmd("filetype plugin indent on")
  local calls = 0
  _G.KnappingTestIndent = function()
    calls = calls + 1
    return 0
  end
  local original = "v:lua.KnappingTestIndent()"
  local knapping = require("knapping").setup()
  -- Reproduce an indenter installed by a later FileType handler.
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
      vim.bo.indentexpr = original
    end,
  })
  vim.bo.filetype = "markdown"
  assert(vim.wait(100, function() return vim.bo.indentexpr ~= original end))
  local wrapped = vim.bo.indentexpr
  assert(wrapped:find("knapping", 1, true))
  vim.bo.textwidth = 38
  local text = "Here is my line-wrapped item continuing to the next line with more words and extra words."
  local function wrap(prefix, width, insert)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { insert and "" or prefix .. text })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    if insert then
      vim.cmd("normal! i" .. prefix .. text .. "\027")
    else
      vim.cmd("normal! gggqG")
    end
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    assert(#lines >= 3, "Exercise multiple continuation lines")
    for i = 2, #lines do
      assert(vim.fn.indent(i) == width, vim.inspect(lines))
    end
  end
  for _, prefix in ipairs({ "- [ ] ", "* [x] ", "+ [/] ", "1. [B] ", "12) [!] ", "  - [ ] " }) do
    wrap(prefix, #prefix, true)
    wrap(prefix, #prefix, false)
  end
  assert(calls > 0, "Delegate to the existing indenter")
  wrap("- ", 0, true)
  wrap("- [z] ", 0, true)
  wrap("", 0, true)

  -- Keep new sibling and nested list items under the original indenter.
  for _, next_line in ipairs({ "      - sibling", "      - [x] sibling", "      1. sibling" }) do
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "- [ ] parent", next_line })
    vim.cmd("normal! G==")
    assert(vim.fn.indent(2) == 0)
  end
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "- [ ] parent", "", "      paragraph" })
  vim.cmd("normal! G==")
  assert(vim.fn.indent(3) == 0, "Stop at paragraph boundaries")

  knapping.setup()
  assert(vim.bo.indentexpr == wrapped, "Do not wrap the wrapper")
  knapping.disable()
  assert(vim.bo.indentexpr == original, "Restore the existing indenter")
  knapping.enable()
  vim.bo.indentexpr = "7"
  knapping.disable()
  assert(vim.bo.indentexpr == "7", "Preserve subsequent user changes")
  vim.bo.indentexpr = ""
  knapping.enable()
  assert(vim.bo.indentexpr == "", "Do not install an indenter where none was set")
end

local ok, err = pcall(test)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
end
print("Checkbox indentexpr tests passed")
vim.cmd("qa!")
