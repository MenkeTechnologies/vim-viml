" vim-viml — language-server / linter wiring for VimL (vimlrs)
"
" vimlrs CLI flags used here:
"   vimlrs FILE.vim     run a script (FILE is POSITIONAL — there is NO -f flag)
"   --lsp               Language Server (JSON-RPC on stdio)
"   --dap               Debug Adapter (DAP on stdio)
"
" NOTE: vimlrs has no standalone lint / parse-check flag (awkrs had `-L`;
" vimlrs does NOT). The ALE linter below therefore RUNS the script
" (`vimlrs %t`) and scrapes the Vim-style errors off stderr; the live,
" non-executing diagnostics path is the LSP.
"
" LSP / DAP: the wiring below registers `vimlrs --lsp` (Language Server,
" JSON-RPC on stdio) and documents `vimlrs --dap` (Debug Adapter, DAP on
" stdio). Each MUST be invoked with ONLY that flag (no appended `--stdio`),
" mirroring `stryke --lsp` / `awkrs --lsp`; vim-lsp / nvim-dap clients must NOT
" add transport args. The wiring is guarded so the plugin still loads cleanly
" if the binary is absent.
"
" Opt-outs:
"   let g:vim_viml_no_ale = 1   " skip ALE linter registration
"   let g:vim_viml_no_lsp = 1   " skip vim-lsp server registration

if exists('g:loaded_vim_viml')
  finish
endif
let g:loaded_vim_viml = 1

" ---------------------------------------------------------------------------
" ALE linter
" ---------------------------------------------------------------------------
function! VimlProjectRoot(buffer) abort
  let l:git = ale#path#FindNearestDirectory(a:buffer, '.git')
  return !empty(l:git) ? fnamemodify(l:git, ':h:h') : expand('#' . a:buffer . ':p:h')
endfunction

function! VimlHandler(buffer, lines) abort
  let l:output = []
  for l:line in a:lines
    " Vim-style with location: "<file>:<line>: <message>" (line/col forms).
    let l:match = matchlist(l:line, '\v^.{-}:(\d+):%(\d+:)?\s*(.+)$')
    if !empty(l:match)
      call add(l:output, {'lnum': l:match[1] + 0, 'text': l:match[2], 'type': 'E'})
      continue
    endif
    " Bare Vim error code on stderr: "E121: Undefined variable: foo".
    let l:match = matchlist(l:line, '\v^(E\d+:\s*.+)$')
    if !empty(l:match)
      call add(l:output, {'lnum': 1, 'text': l:match[1], 'type': 'E'})
    endif
  endfor
  return l:output
endfunction

function! s:RegisterVimlALE() abort
  if get(g:, 'vim_viml_no_ale', 0)
    return
  endif
  if exists('*ale#linter#Define')
    " No lint flag exists; run the script (positional %t) and scrape stderr.
    call ale#linter#Define('vim', {
    \   'name': 'vimlrs',
    \   'executable': 'vimlrs',
    \   'command': 'vimlrs %t 2>&1',
    \   'callback': 'VimlHandler',
    \   'project_root': function('VimlProjectRoot'),
    \})
    let g:ale_linters = get(g:, 'ale_linters', {})
    let g:ale_linters.vim = ['vimlrs']
  endif
endfunction

augroup vim_viml_ale
  autocmd!
  autocmd VimEnter * call s:RegisterVimlALE()
augroup END

" ---------------------------------------------------------------------------
" vim-lsp
" ---------------------------------------------------------------------------
if !get(g:, 'vim_viml_no_lsp', 0) && exists('*lsp#register_server')
  call lsp#register_server({
  \   'name': 'vimlrs',
  \   'cmd': ['vimlrs', '--lsp'],
  \   'allowlist': ['vim'],
  \})
endif

" ---------------------------------------------------------------------------
" coc.nvim — add to coc-settings.json:
"   {
"     "languageserver": {
"       "vimlrs": {
"         "command": "vimlrs",
"         "args": ["--lsp"],
"         "filetypes": ["vim"]
"       }
"     }
"   }
" ---------------------------------------------------------------------------

" ---------------------------------------------------------------------------
" nvim-dap — add to your Neovim config (debug adapter via `vimlrs --dap`):
"   local dap = require('dap')
"   dap.adapters.vimlrs = {
"     type = 'executable',
"     command = 'vimlrs',
"     args = { '--dap' },   -- no extra transport args; vimlrs rejects them
"   }
"   dap.configurations.vim = {
"     { type = 'vimlrs', request = 'launch', name = 'Run VimL program',
"       program = '${file}' },
"   }
" ---------------------------------------------------------------------------
