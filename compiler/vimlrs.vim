" vim-viml — :compiler vimlrs
"
" Wires `:make` to run the current VimL program through the vimlrs binary,
" so parse / compile / runtime diagnostics land in the quickfix list. Flags
" verified against `vimlrs --help`:
"   vimlrs FILE.vim     run a script (FILE is POSITIONAL — there is NO -f flag)
"   -e, --expr <EXPR>   evaluate an expression
"   -c, --cmd <CMD>     run an ex command
"
" NOTE: vimlrs has no standalone lint / parse-check mode yet (awkrs had
" `-L`; vimlrs does NOT). Running the script is what surfaces parse / compile
" errors — they print on stderr as Vim-style messages (e.g.
" "E121: Undefined variable: foo"). For live, non-executing diagnostics use
" the LSP (`vimlrs --lsp`, wired in plugin/vim.vim).

if exists('current_compiler')
  finish
endif
let current_compiler = 'vimlrs'

if exists(':CompilerSet') != 2
  command -nargs=* CompilerSet setlocal <args>
endif

" `vimlrs %` runs the current buffer's program; the file is the positional arg.
CompilerSet makeprg=vimlrs\ %

" vimlrs / Vim-style diagnostics. Common forms:
"   file:line:col: message
"   file:line: message
"   E121: Undefined variable: foo      (bare Vim error code on stderr)
CompilerSet errorformat=%f:%l:%c:\ %m
CompilerSet errorformat+=%f:%l:\ %m
CompilerSet errorformat+=%t%n:\ %m\ in\ %f:%l
CompilerSet errorformat+=%t%n:\ %m
CompilerSet errorformat+=%m
