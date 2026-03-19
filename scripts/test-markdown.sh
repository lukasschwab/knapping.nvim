#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TARGET_FILE=${1:-}

if [ -z "$TARGET_FILE" ]; then
  TARGET_FILE="$ROOT_DIR/test.md"
fi

if [ ! -f "$TARGET_FILE" ]; then
  cat >"$TARGET_FILE" <<'EOF'
- [ ] to-do
- [/] incomplete
- [x] done
- [-] canceled
- [>] forwarded
- [<] scheduled
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
EOF
fi

exec nvim -u NONE -i NONE -n \
  --cmd "set runtimepath+=$ROOT_DIR" \
  --cmd "filetype plugin indent on" \
  --cmd "syntax enable" \
  --cmd "set termguicolors" \
  --cmd "colorscheme habamax" \
  "$TARGET_FILE" \
  -c "lua require('knapping').setup({ use_nerd_font = true })"
