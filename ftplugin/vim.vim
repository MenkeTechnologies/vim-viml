" vim-viml — filetype-local settings for VimL (Vimscript) buffers
"
" Vim ships its own stock vim-ftplugin (which sets b:did_ftplugin). We want to
" AUGMENT it — add the vimlrs run/make wiring — not replace it, so we guard on
" our own b:did_ftplugin_vimlrs marker instead of b:did_ftplugin.

if exists('b:did_ftplugin_vimlrs')
  finish
endif
let b:did_ftplugin_vimlrs = 1

" VimL comments run '"' to end of line (in command position). The literal
" backslash-space is Vim's commentstring escape for the leading-space leader.
setlocal commentstring=\"\ %s
setlocal comments=:\"

" Continue the comment leader on <Enter> / o / O, recognize numbered lists.
setlocal formatoptions-=t
setlocal formatoptions+=croql

" Run the current VimL program through vimlrs. `:make` uses the vimlrs compiler
" (compiler/vimlrs.vim); :VimlRun executes the buffer through vimlrs directly.
" Guard the :compiler call so the file still sources cleanly when the plugin
" dir is not yet on runtimepath (e.g. an isolated `:source`).
if !empty(globpath(&runtimepath, 'compiler/vimlrs.vim'))
  compiler vimlrs
else
  " vimlrs has no standalone lint/parse-check flag (no awk-style -L); running
  " the script surfaces parse / compile errors on stderr. The live diagnostics
  " path is the LSP (see plugin/vim.vim). The file is a positional arg — there
  " is NO -f flag.
  setlocal makeprg=vimlrs\ %
  setlocal errorformat=%f:%l:%c:\ %m,%f:%l:\ %m,%t%n:\ %m,%m
endif

if !exists(':VimlRun')
  " vimlrs takes the script as a POSITIONAL argument (no -f flag).
  command! -buffer -nargs=* -complete=file VimlRun
        \ echo system('vimlrs ' . shellescape(expand('%:p')) . ' ' . <q-args>)
endif

" <LocalLeader>r runs the current file via `vimlrs %`.
if !get(g:, 'vim_viml_no_maps', 0)
  nnoremap <buffer> <silent> <LocalLeader>r :VimlRun<CR>
endif

" Restore on filetype change.
let b:undo_ftplugin = 'setlocal commentstring< comments< formatoptions<'
      \ . '| silent! nunmap <buffer> <LocalLeader>r'
      \ . '| silent! delcommand VimlRun'
