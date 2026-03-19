# Usage

To test in an otherwise-unconfigured nvim:

```console
$ ./scripts/test-markdown.sh
```

## Basic

- [ ] to-do
- [/] incomplete
- [x] done
- [-] canceled
- [>] forwarded
- [<] scheduling

### Nested checkboxes

- [ ] parent task
  - [x] child task
  - [/] child in progress
    - [!] deeper child

> - [ ] checkbox inside blockquote
>   - [x] nested checkbox inside blockquote

## Extras

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

## Callouts

> [!NOTE] Obsidian note
> This is a basic callout using the shared `[!TYPE]` syntax.
> GitHub alerts use the same marker for `NOTE`, `TIP`, `IMPORTANT`, `WARNING`, and `CAUTION`.

> [!TIP] Custom title
> You can add a title after the callout marker.
> > Nested plain blockquote text should keep the outer callout delimiter color.

> [!WARNING] Nested callouts
> Outer callout body.
> > [!QUESTION] Inner callout
> > Inner body text.
> >
> > - [ ] nested checkbox inside nested callout
> Back in the outer callout.

> [!CAUTION]- Fold marker
> Fold markers are part of the syntax and should be highlighted with the title.
