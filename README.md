```
██╗   ██╗██╗███╗   ███╗     ██╗   ██╗██╗███╗   ███╗██╗
██║   ██║██║████╗ ████║     ██║   ██║██║████╗ ████║██║
██║   ██║██║██╔████╔██║     ██║   ██║██║██╔████╔██║██║
╚██╗ ██╔╝██║██║╚██╔╝██║     ╚██╗ ██╔╝██║██║╚██╔╝██║██║
 ╚████╔╝ ██║██║ ╚═╝ ██║      ╚████╔╝ ██║██║ ╚═╝ ██║███████╗
  ╚═══╝  ╚═╝╚═╝     ╚═╝       ╚═══╝  ╚═╝╚═╝     ╚═╝╚══════╝
```

[![CI](https://github.com/MenkeTechnologies/vim-viml/actions/workflows/ci.yml/badge.svg)](https://github.com/MenkeTechnologies/vim-viml/actions/workflows/ci.yml)
[![Docs](https://img.shields.io/badge/docs-online-05d9e8.svg)](https://menketechnologies.github.io/vim-viml/)
[![Syntax](https://img.shields.io/badge/syntax-standalone%20VimL-ff2a6d.svg)](https://menketechnologies.github.io/vim-viml/)
[![LSP](https://img.shields.io/badge/LSP%20%2F%20DAP-vimlrs-39ff14.svg)](https://github.com/MenkeTechnologies/vim-viml)
[![License: MIT](https://img.shields.io/badge/License-MIT-d300c5.svg)](https://opensource.org/licenses/MIT)

### `[VIM PLUGIN // NEON SYNTAX // STANDALONE VIML GRAMMAR // ALE + LSP + DAP]`

> *"Load it with pathogen. Open a `.vim`. It lights up."*

Vim / Neovim support for **VimL (Vimscript)**, targeting **vimlrs** — a standalone Vimscript interpreter, a Rust port of Neovim's eval engine running on fusevm. Standalone syntax highlighting, filetype detection, keyword-aware indentation, `:make` / `:VimlRun` wiring, ALE linting, and vim-lsp / coc.nvim / nvim-dap integration. Zero configuration.

```bash
cd ~/.vim/bundle && git clone https://github.com/MenkeTechnologies/vim-viml   # pathogen
```

### [`Read the Docs`](https://menketechnologies.github.io/vim-viml/) &middot; [`Engineering Report`](https://menketechnologies.github.io/vim-viml/report.html)

---

## [0x00] OVERVIEW

**vim-viml** is Vim / Neovim support for **VimL (Vimscript)** — targeting **vimlrs**, a Rust port of Neovim's eval engine running on fusevm. It ships as a standard Vim runtime tree, so **pathogen / vim-plug / native packages** add it to `runtimepath` with zero special handling and zero configuration.

The syntax file is a **standalone VimL grammar** covering the eval-engine surface vimlrs implements — statement keywords, common ex commands, scope-sigil variables, the special `v:` vars, and the curated builtin-function subset vimlrs ports from Neovim's `funcs.c`. The keyword / builtin lists are hand-curated; `scripts/gen_syntax.sh` stamps the file with the vimlrs version it was verified against. The runtime **augments** Vim's built-in `vim` filetype (the ftplugin guards on its own `b:did_ftplugin_vimlrs` marker), layering the vimlrs run / make / LSP wiring on top of the stock runtime files.

- **statements** — `if` `elseif` `else` `endif` `while` `for` `function` `return` `try` `catch` `finally` `let` `const` `call` `execute` `echo` …
- **scope vars** — `g:` `s:` `b:` `w:` `t:` `l:` `a:` `v:` (+ `&option`, `$ENV`, `@register`) and the `v:true` / `v:count` / `v:val` special vars
- **builtin functions** — `add` `get` `has_key` `keys` `len` `map` `filter` `match` `printf` `range` `reduce` `sort` `split` `string` `substitute` `type` (+ `sin` `cos` `sqrt` `pow`, bit `and`/`or`/`xor`, `json_encode`/`json_decode`, …)

> The `vimlrs` binary must be on `$PATH` for running, linting and LSP.

---

## [0x01] FEATURE MATRIX

| Capability | Status |
|---|---|
| Filetype detection — `*.vim` | **Implemented** — every `*.vim` buffer becomes `filetype=vim` |
| Filetype detection — rc family | **Implemented** — `vimrc` `.vimrc` `gvimrc` `.exrc` `.nvimrc` `init.vim` … are detected |
| Filetype detection — shebang | **Implemented** — extensionless scripts with `#!/usr/bin/env vimlrs` (or vim / nvim) are detected |
| Syntax highlighting | **Implemented** — standalone VimL grammar (statements, ex commands, scope vars, `v:` vars, builtin functions, strings, numbers, operators) |
| Indentation | **Implemented** — standalone keyword-aware indenter |
| Comments | **Implemented** — `commentstring=" %s`, comment-continuation `formatoptions` |
| Run / make | **Implemented** — `:compiler vimlrs` (`:make` → quickfix) and `:VimlRun` (`<LocalLeader>r`) |
| Linting | **Implemented** — ALE linter running `vimlrs %t` |
| Language server (vim-lsp) | **Implemented** — `vimlrs --lsp`, allowlisted for `vim` |
| Language server (coc.nvim) | **Implemented** — ready-to-paste `languageserver` config |
| Debug adapter (nvim-dap) | **Implemented** — ready-to-paste `vimlrs --dap` adapter config |
| Help | **Implemented** — `:help vim-viml` |
| Config required | **None** — opt-outs to disable ALE, LSP, or the run mapping |

---

## [0x02] INSTALL

**pathogen**

```bash
cd ~/.vim/bundle
git clone https://github.com/MenkeTechnologies/vim-viml
# then inside vim:  :Helptags
```

**vim-plug** (add to `~/.vimrc` / `init.vim`)

```vim
Plug 'MenkeTechnologies/vim-viml'
```

**native packages** (Vim 8+ / Neovim)

```bash
git clone https://github.com/MenkeTechnologies/vim-viml \
    ~/.vim/pack/plugins/start/vim-viml
```

Open any `.vim` file and it lights up — no further configuration. See `:help vim-viml`.

---

## [0x03] SYNTAX // TOKEN CATEGORIES

The grammar classifies tokens into the categories the VimL language defines — the eval-engine surface vimlrs implements:

| Category | Tokens (sample) | Highlight |
|---|---|---|
| Statements / control flow | `if` `elseif` `else` `endif` `while` `for` `function` `return` `try` `catch` `finally` `let` `const` `call` `execute` `echo` `throw` `finish` | `Statement` |
| Ex commands | `source` `runtime` `normal` `set` `setlocal` `command` `autocmd` `augroup` `highlight` `syntax` `map` `noremap` `nnoremap` `sign` `sleep` | `PreProc` |
| Scope variables | `g:` `s:` `b:` `w:` `t:` `l:` `a:` `v:` · `&option` · `$ENV` · `@reg` | `Identifier` / `Special` |
| Special `v:` vars | `v:true` `v:false` `v:null` `v:count` `v:val` `v:key` `v:exception` `v:lnum` `v:errmsg` `v:shell_error` | `Constant` |
| Builtin functions | `add` `copy` `extend` `filter` `get` `has_key` `index` `insert` `items` `join` `keys` `len` `map` `match` `max` `min` `range` `reduce` `remove` `repeat` `reverse` `sort` `split` `string` `substitute` `trim` `type` `values` | `Function` |
| Math / bit / JSON | `abs` `ceil` `cos` `floor` `fmod` `pow` `round` `sin` `sqrt` · `and` `or` `xor` `invert` · `json_encode` `json_decode` | `Function` |
| Numbers & strings | decimal / `0x` hex / float · `'literal'` · `"escaped\n"` | `Number` / `String` |

Command-position `"` comments, single-quoted literal strings, double-quoted strings with escapes, and the full operator set (including `.` / `..` concat and `=~` / `!~` match) are handled too. Everything links to standard highlight groups, so every colorscheme covers it.

> VimL comment caveat: a `"` is a comment only in command position; in expression position it opens a double-quoted string. The grammar handles the common full-line / trailing-comment cases pragmatically, as Vim's own runtime syntax does.

---

## [0x04] RUN // LINT

`:compiler vimlrs` wires `:make` to run the current program through vimlrs and route any parse / compile / runtime diagnostics to the quickfix list:

```bash
vimlrs %
```

vimlrs takes the script as a **positional** argument — there is no `-f` flag. To execute the current buffer as a VimL program: `:VimlRun [args...]` (mapped to `<LocalLeader>r`).

When **[ALE](https://github.com/dense-analysis/ale)** is installed, vim-viml registers a linter that runs `vimlrs %t` inline. Because vimlrs has no standalone lint flag yet, the linter runs the script and scrapes the Vim-style errors (e.g. `E121: Undefined variable: foo`) off stderr; the live, non-executing diagnostics path is the LSP. Skipped silently if ALE is absent or `g:vim_viml_no_ale` is set.

---

## [0x05] LANGUAGE SERVER

### vim-lsp

Registered automatically as `vimlrs --lsp`, allowlisted for the `vim` filetype — no extra config when **[vim-lsp](https://github.com/prabirshrestha/vim-lsp)** is installed. vimlrs must be invoked with **only** `--lsp` — it rejects an appended `--stdio`, so do not add transport args.

### coc.nvim

Add to `coc-settings.json`:

```json
{
  "languageserver": {
    "vimlrs": {
      "command": "vimlrs",
      "args": ["--lsp"],
      "filetypes": ["vim"]
    }
  }
}
```

---

## [0x06] DEBUG ADAPTER

vimlrs exposes a Debug Adapter via `vimlrs --dap` (DAP on stdio). For **[nvim-dap](https://github.com/mfussenegger/nvim-dap)**, add to your Neovim config:

```lua
local dap = require('dap')
dap.adapters.vimlrs = {
  type = 'executable',
  command = 'vimlrs',
  args = { '--dap' },   -- no extra transport args; vimlrs rejects them
}
dap.configurations.vim = {
  { type = 'vimlrs', request = 'launch', name = 'Run VimL program',
    program = '${file}' },
}
```

---

## [0x07] OPTIONS

Set before the plugin loads (e.g. in your `vimrc`):

| Variable | Effect |
|---|---|
| `let g:vim_viml_no_ale = 1` | Skip ALE linter registration |
| `let g:vim_viml_no_lsp = 1` | Skip vim-lsp server registration |
| `let g:vim_viml_no_maps = 1` | Skip the `<LocalLeader>r` run mapping |

---

## [0x08] LAYOUT

```
vim-viml/
├── ftdetect/vim.vim     # *.vim + rc family + vimlrs / vim / nvim shebang -> filetype=vim
├── syntax/vim.vim       # standalone VimL grammar (statements / ex cmds / builtins)
├── scripts/gen_syntax.sh # stamps syntax/vim.vim with the vimlrs version
├── ftplugin/vim.vim     # commentstring '" %s', :compiler vimlrs, :VimlRun
├── compiler/vimlrs.vim  # :make via vimlrs % -> quickfix
├── indent/vim.vim       # standalone keyword-aware indenter
├── plugin/vim.vim       # ALE linter + vim-lsp + coc + nvim-dap wiring
└── doc/vimlrs.txt       # :help vim-viml
```

Standard Vim runtime layout — pathogen / vim-plug / native packages add it to `runtimepath` with no special handling. It augments Vim's built-in `vim` filetype rather than replacing it.

---

## [0x09] LICENSE

MIT © **[MenkeTechnologies](https://github.com/MenkeTechnologies)**
