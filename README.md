# knapping.nvim

Extra Markdown highlighting for Neovim, loosely based on the checkbox styling and palette from the [Obsidian Things theme](https://github.com/colineckert/obsidian-things?tab=readme-ov-file#checkbox-styling).

Current scope:

- colors the whole checkbox token, including brackets, with a Things-inspired palette
- aligns wrapped checkbox items with their text
- conceals checkbox tokens to symbols when a Nerd Font is available
- highlights Obsidian-style callout headers and colors the `>` delimiters for the whole callout block
- mutes HTML-style Markdown comments outside fenced code blocks

<img width="1020" height="1401" alt="Screenshot of nvim showing ./test.md wiht knapping.nvim enabled" src="https://github.com/user-attachments/assets/003be499-f8df-44aa-9089-4244e68c03d0" />

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
- [B] blocked
- [i] information
- [S] savings
- [I] idea
- [p] pros
- [O] open pull request
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

### Line wrapping

With Neovim's built-in Markdown formatting, checkbox items wrap beneath their
text in Insert mode and when formatting with `gq`:

```markdown
- [ ] Here is my line-wrapped item
      continuing to the next line.
```

This applies to all supported checkbox states, with standard bullet spacing
(`- [ ]`, `* [ ]`, `+ [ ]`) and numbered items (`1. [ ]`, `1) [ ]`). Ordinary
lists and custom list patterns retain their existing behavior. Knapping extends
the buffer's `formatlistpat` and first-line comment leaders; disabling Knapping
restores these options unless you have changed them since. Your `textwidth`,
`autoindent`, and `formatoptions` settings still control when wrapping happens
(list indentation uses `autoindent` and the `n` flag in `formatoptions`).

If an `indentexpr` is configured (for example, Tree-sitter indentation), Knapping
delegates to it while preserving the checkbox continuation indent already added
by hard wrapping. Disabling Knapping restores the original expression too.

`[B]` (blocked) uses a rusty-red color and a Nerd Font octagonal stop icon
(`nf-oct-stop`). Override `palette.light.rust`, `palette.dark.rust`, or
`symbols.blocked` to customize its appearance.

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
  use_nerd_font = false,
})
```

Notes:

- `use_nerd_font = false` is the default; set it to `true` explicitly when you know your terminal or GUI font supports the glyphs you want
- Nerd Font symbols are drawn as overlays, so knapping no longer needs to change window `conceallevel`
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
