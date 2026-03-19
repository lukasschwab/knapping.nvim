# knapping.nvim

Extra Markdown highlighting for Neovim, loosely based on the checkbox styling and palette from the [Obsidian Things theme](https://github.com/colineckert/obsidian-things?tab=readme-ov-file#checkbox-styling).

Current scope:

- colors the whole checkbox token, including brackets, with a Things-inspired palette
- conceals checkbox tokens to symbols when a Nerd Font is available
- highlights Obsidian-style callout headers and colors the `>` delimiters for the whole callout block

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

Nested checkboxes are supported in indented lists and inside blockquotes because knapping matches the checkbox token after stripping Markdown list and blockquote prefixes.

## Supported callouts

Knapping highlights Obsidian callouts written as blockquotes with a `[!TYPE]` header:

```markdown
> [!NOTE]
> A basic callout.

> [!TIP] Custom title
> A callout with a custom title.

> [!WARNING]
> Outer callout
> > [!QUESTION]
> > Nested callout
```

Supported aliases include:

- `note`
- `abstract`, `summary`, `tldr`
- `info`
- `todo`
- `tip`, `hint`
- `important`
- `success`, `check`, `done`
- `question`, `help`, `faq`
- `warning`, `caution`, `attention`
- `failure`, `fail`, `missing`
- `danger`, `error`
- `bug`
- `example`
- `quote`, `cite`

GitHub alerts are supported as a documented subset:

- `NOTE`
- `TIP`
- `IMPORTANT`
- `WARNING`
- `CAUTION`

Knapping supports nested callouts in source buffers by tracking callouts by quote depth and coloring each active `>` delimiter separately.

## Installation

### `lazy.nvim`

```lua
{
  "YOUR_GITHUB_USER/knapping.nvim",
  ft = "markdown",
  opts = {
    use_nerd_font = true,   -- or false!
  },
}
```

### Plain `runtimepath`

```lua
vim.opt.rtp:append("~/Programming/knapping.nvim")
require("knapping").setup({
  use_nerd_font = true,     -- or false!
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
