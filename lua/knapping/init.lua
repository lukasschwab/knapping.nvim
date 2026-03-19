local M = {}

local namespace = vim.api.nvim_create_namespace("knapping")
local augroup = vim.api.nvim_create_augroup("Knapping", { clear = true })

local defaults = {
  filetypes = { "markdown" },
  use_nerd_font = nil,
  set_conceallevel = true,
  palette = {
    light = {
      accent = "#086ddd",
      muted = "#ababab",
      red = "#e4374b",
      green = "#0cb54f",
      orange = "#d96c00",
      yellow = "#bd8e37",
      cyan = "#2db7b5",
      blue = "#086ddd",
      purple = "#876be0",
    },
    dark = {
      accent = "#027aff",
      muted = "#666666",
      red = "#fb464c",
      green = "#44cf6e",
      orange = "#e9973f",
      yellow = "#e0de71",
      cyan = "#53dfdd",
      blue = "#027aff",
      purple = "#a882ff",
    },
  },
  symbols = {
    todo = "",
    done = "",
    incomplete = "◪",
    canceled = "",
    forwarded = "",
    scheduled = "",
    question = "",
    important = "",
    star = "",
    quote = "",
    location = "",
    bookmark = "",
    information = "",
    savings = "",
    idea = "",
    pros = "",
    cons = "",
    fire = "",
    key = "",
    win = "",
    up = "",
    down = "",
    draft_pr = "◌",
    open_pr = "",
    merged_pr = "",
  },
}

local checkbox_styles = {
  [" "] = { name = "todo", tone = "muted", symbol = "todo" },
  ["x"] = { name = "done", tone = "muted", symbol = "done" },
  ["X"] = { name = "done", tone = "muted", symbol = "done" },
  ["/"] = { name = "incomplete", tone = "accent", symbol = "incomplete" },
  ["-"] = { name = "canceled", tone = "muted", symbol = "canceled" },
  [">"] = { name = "forwarded", tone = "muted", symbol = "forwarded" },
  ["<"] = { name = "scheduled", tone = "muted", symbol = "scheduled" },
  ["?"] = { name = "question", tone = "yellow", symbol = "question" },
  ["!"] = { name = "important", tone = "orange", symbol = "important" },
  ["*"] = { name = "star", tone = "yellow", symbol = "star" },
  ['"'] = { name = "quote", tone = "cyan", symbol = "quote" },
  ["“"] = { name = "quote", tone = "cyan", symbol = "quote" },
  ["l"] = { name = "location", tone = "red", symbol = "location" },
  ["b"] = { name = "bookmark", tone = "orange", symbol = "bookmark" },
  ["i"] = { name = "information", tone = "blue", symbol = "information" },
  ["S"] = { name = "savings", tone = "green", symbol = "savings" },
  ["I"] = { name = "idea", tone = "yellow", symbol = "idea" },
  ["p"] = { name = "pros", tone = "green", symbol = "pros" },
  ["c"] = { name = "cons", tone = "orange", symbol = "cons" },
  ["f"] = { name = "fire", tone = "red", symbol = "fire" },
  ["k"] = { name = "key", tone = "yellow", symbol = "key" },
  ["w"] = { name = "win", tone = "purple", symbol = "win" },
  ["u"] = { name = "up", tone = "green", symbol = "up" },
  ["d"] = { name = "down", tone = "red", symbol = "down" },
  ["D"] = { name = "draft_pr", tone = "muted", symbol = "draft_pr" },
  ["P"] = { name = "open_pr", tone = "green", symbol = "open_pr" },
  ["M"] = { name = "merged_pr", tone = "purple", symbol = "merged_pr" },
}

local state = {
  config = vim.deepcopy(defaults),
  attached = {},
  configured = false,
}

local function merge_config(user_config)
  state.config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), user_config or {})
end

local function is_target_filetype(filetype)
  return vim.tbl_contains(state.config.filetypes, filetype)
end

local function current_palette()
  if vim.o.background == "light" then
    return state.config.palette.light
  end

  return state.config.palette.dark
end

local function extract_fg(name)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if not ok or not hl or not hl.fg then
    return nil
  end

  return string.format("#%06x", hl.fg)
end

local function resolved_accent()
  local palette = current_palette()
  local accent = palette.accent

  for _, group in ipairs({ "Special", "Identifier", "Function", "Title" }) do
    local fg = extract_fg(group)
    if fg then
      accent = fg
      break
    end
  end

  return accent
end

local function define_highlights()
  local palette = current_palette()
  local tones = vim.deepcopy(palette)
  tones.accent = resolved_accent()

  local seen = {}
  for _, style in pairs(checkbox_styles) do
    if not seen[style.name] then
      seen[style.name] = true
      vim.api.nvim_set_hl(0, "KnappingCheckbox" .. style.name, {
        fg = tones[style.tone],
        nocombine = true,
      })
    end
  end
end

local function has_nerd_font()
  if state.config.use_nerd_font ~= nil then
    return state.config.use_nerd_font
  end

  if vim.g.have_nerd_font ~= nil then
    return vim.g.have_nerd_font
  end

  if vim.g.nerd_font ~= nil then
    return vim.g.nerd_font
  end

  if vim.g.have_nf ~= nil then
    return vim.g.have_nf
  end

  if vim.fn.has("gui_running") == 1 and vim.o.guifont ~= "" then
    return vim.o.guifont:find("Nerd Font", 1, true) ~= nil
  end

  return false
end

local function use_symbols()
  return has_nerd_font()
end

local function apply_window_settings(bufnr)
  if not use_symbols() or not state.config.set_conceallevel then
    return
  end

  for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
    local ok = pcall(vim.api.nvim_win_get_var, winid, "knapping_prev_conceallevel")
    if not ok then
      vim.api.nvim_win_set_var(winid, "knapping_prev_conceallevel", vim.wo[winid].conceallevel)
    end

    if vim.wo[winid].conceallevel < 2 then
      vim.wo[winid].conceallevel = 2
    end
  end
end

local function restore_window_settings(bufnr)
  for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
    local ok, previous = pcall(vim.api.nvim_win_get_var, winid, "knapping_prev_conceallevel")
    if ok then
      vim.wo[winid].conceallevel = previous
      pcall(vim.api.nvim_win_del_var, winid, "knapping_prev_conceallevel")
    end
  end
end

local function restore_current_window_setting()
  local winid = vim.api.nvim_get_current_win()
  local ok, previous = pcall(vim.api.nvim_win_get_var, winid, "knapping_prev_conceallevel")
  if ok then
    vim.wo[winid].conceallevel = previous
    pcall(vim.api.nvim_win_del_var, winid, "knapping_prev_conceallevel")
  end
end

local function strip_quote_prefix(prefix)
  local rest = prefix
  while true do
    local stripped, replaced = rest:gsub("^%s*>%s*", "", 1)
    if replaced == 0 then
      break
    end
    rest = stripped
  end

  return rest
end

local function is_task_prefix(prefix)
  local rest = strip_quote_prefix(prefix)

  if rest:match("^%s*[-*+]%s+$") then
    return true
  end

  if rest:match("^%s*%d+[.)]%s+$") then
    return true
  end

  return false
end

local function find_checkbox(line)
  local from = 1

  while true do
    local start_col, end_col, marker = line:find("%[([^%]])%]", from)
    if not start_col then
      return nil
    end

    if checkbox_styles[marker] and is_task_prefix(line:sub(1, start_col - 1)) then
      return start_col, end_col, marker
    end

    from = end_col + 1
  end
end

local function refresh_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  if not state.attached[bufnr] or not is_target_filetype(vim.bo[bufnr].filetype) then
    return
  end

  apply_window_settings(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local show_symbols = use_symbols()

  for row, line in ipairs(lines) do
    local start_col, end_col, marker = find_checkbox(line)
    if start_col then
      local style = checkbox_styles[marker]
      local extmark = {
        end_row = row - 1,
        end_col = end_col,
        hl_group = "KnappingCheckbox" .. style.name,
        right_gravity = false,
      }

      if show_symbols then
        extmark.conceal = state.config.symbols[style.symbol] or marker
      end

      vim.api.nvim_buf_set_extmark(bufnr, namespace, row - 1, start_col - 1, extmark)
    end
  end
end

local function attach_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or state.attached[bufnr] then
    return
  end

  if not is_target_filetype(vim.bo[bufnr].filetype) then
    return
  end

  state.attached[bufnr] = true

  local buffer_group = vim.api.nvim_create_augroup("KnappingBuffer" .. bufnr, { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TextChanged", "TextChangedI", "InsertLeave" }, {
    group = buffer_group,
    buffer = bufnr,
    callback = function()
      refresh_buffer(bufnr)
    end,
  })

  vim.api.nvim_create_autocmd("BufWinLeave", {
    group = buffer_group,
    buffer = bufnr,
    callback = function()
      restore_current_window_setting()
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = buffer_group,
    buffer = bufnr,
    once = true,
    callback = function()
      restore_window_settings(bufnr)
      state.attached[bufnr] = nil
      pcall(vim.api.nvim_del_augroup_by_id, buffer_group)
    end,
  })

  refresh_buffer(bufnr)
end

local function detach_buffer(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  restore_window_settings(bufnr)
  state.attached[bufnr] = nil
  pcall(vim.api.nvim_del_augroup_by_name, "KnappingBuffer" .. bufnr)
end

local function refresh_all()
  define_highlights()

  for bufnr, _ in pairs(state.attached) do
    refresh_buffer(bufnr)
  end
end

local function enable_existing_buffers()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and is_target_filetype(vim.bo[bufnr].filetype) then
      attach_buffer(bufnr)
    end
  end
end

local function disable_non_target_buffers()
  for bufnr, _ in pairs(state.attached) do
    if not is_target_filetype(vim.bo[bufnr].filetype) then
      detach_buffer(bufnr)
    end
  end
end

local function create_global_autocmds()
  vim.api.nvim_clear_autocmds({ group = augroup })

  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = state.config.filetypes,
    callback = function(event)
      attach_buffer(event.buf)
    end,
  })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = function()
      refresh_all()
    end,
  })

  vim.api.nvim_create_autocmd("OptionSet", {
    group = augroup,
    pattern = "background",
    callback = function()
      refresh_all()
    end,
  })
end

function M.refresh(bufnr)
  if bufnr then
    refresh_buffer(bufnr)
    return
  end

  refresh_all()
end

function M.enable(bufnr)
  attach_buffer(bufnr or vim.api.nvim_get_current_buf())
end

function M.disable(bufnr)
  detach_buffer(bufnr or vim.api.nvim_get_current_buf())
end

function M.setup(user_config)
  merge_config(user_config)
  create_global_autocmds()
  define_highlights()

  if state.configured then
    disable_non_target_buffers()
    enable_existing_buffers()
    refresh_all()
    return M
  end

  vim.api.nvim_create_user_command("KnappingRefresh", function()
    refresh_all()
  end, { desc = "Refresh knapping checkbox highlights" })

  vim.api.nvim_create_user_command("KnappingEnable", function()
    attach_buffer(vim.api.nvim_get_current_buf())
  end, { desc = "Enable knapping in the current buffer" })

  vim.api.nvim_create_user_command("KnappingDisable", function()
    detach_buffer(vim.api.nvim_get_current_buf())
  end, { desc = "Disable knapping in the current buffer" })

  state.configured = true
  enable_existing_buffers()

  return M
end

return M
