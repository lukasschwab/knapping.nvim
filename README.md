# knapping.nvim

Extra Markdown checkbox highlighting for Neovim, loosely based on the checkbox styling from the [Obsidian Things theme](https://github.com/colineckert/obsidian-things?tab=readme-ov-file#checkbox-styling).

Current scope:

- colors the whole checkbox token, including brackets, with a Things-inspired palette
- supports alternate task markers such as `[/]`, `[-]`, `[!]`, `[?]`, `[P]`, `[M]`, and more
- conceals checkbox tokens to symbols when a Nerd Font is available

## Supported checkboxes

```markdown
- [ ] to-do
- [/] incomplete
- [x] done
- [-] canceled
- [>] forwarded
- [<] scheduling
- [?] question
- [!] important
- [*] star
- ["] quote
- [l] location
- [b] bookmark
- [i] information
- [S] savings
- [I] idea
- [p] pros
- [c] cons
- [f] fire
- [k] key
- [w] win
- [u] up
- [d] down
- [D] draft pull request
- [P] open pull request
- [M] merged pull request
```

## Installation

### `lazy.nvim`

If you are developing this plugin locally, point `lazy.nvim` at the directory directly:

```lua
{
  dir = "~/Programming/knapping.nvim",
  name = "knapping.nvim",
  ft = "markdown",
  opts = {
    use_nerd_font = vim.g.have_nerd_font,
  },
}
```

Once the repository is published, the same setup becomes:

```lua
{
  "YOUR_GITHUB_USER/knapping.nvim",
  ft = "markdown",
  opts = {
    use_nerd_font = vim.g.have_nerd_font,
  },
}
```

### Plain `runtimepath`

```lua
vim.opt.rtp:append("~/Programming/knapping.nvim")
require("knapping").setup({
  use_nerd_font = vim.g.have_nerd_font,
})
```

## Configuration

Default configuration:

```lua
require("knapping").setup({
  filetypes = { "markdown" },
  use_nerd_font = nil,
  set_conceallevel = true,
})
```

Notes:

- `use_nerd_font = nil` uses a best-effort check: `vim.g.have_nerd_font`, `vim.g.nerd_font`, `vim.g.have_nf`, or `guifont`.
- when Nerd Font symbols are enabled, knapping raises `conceallevel` to `2` in Markdown windows unless `set_conceallevel = false`
- if conceal is disabled in a window, you still get the colored `[x]` token fallback
- `palette` and `symbols` are fully overridable if you want different colors or glyphs

Example override:

```lua
require("knapping").setup({
  use_nerd_font = true,
  palette = {
    dark = {
      accent = "#7aa2f7",
      muted = "#6b7280",
    },
  },
  symbols = {
    incomplete = "◐",
    draft_pr = "",
  },
})
```

## Commands

- `:KnappingRefresh`
- `:KnappingEnable`
- `:KnappingDisable`
