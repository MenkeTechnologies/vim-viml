" vim-viml — filetype detection for VimL (Vimscript) source
" Loaded automatically by pathogen / vim-plug / native packages via ftdetect/.
"
" This AUGMENTS Vim's built-in `vim` filetype: by also claiming the vimrc /
" gvimrc / exrc family and the vimlrs shebang, extensionless scripts light up
" with the same vim runtime files (and our vimlrs tooling) too.

" By extension: every *.vim file is VimL.
autocmd BufNewFile,BufRead *.vim setfiletype vim

" By well-known filename: the rc / init family carries no .vim extension but is
" still Vimscript. Match the editor's own runtime convention.
autocmd BufNewFile,BufRead vimrc,.vimrc,_vimrc,gvimrc,.gvimrc,_gvimrc setfiletype vim
autocmd BufNewFile,BufRead .exrc,_exrc,.nvimrc,init.vim setfiletype vim

" By shebang: files run as `#!/usr/bin/env vimlrs` (or a direct vimlrs / vim /
" nvim path) with no .vim extension still light up. Honor the vimlrs shebang
" for extensionless scripts too.
autocmd BufNewFile,BufRead * call s:DetectVimlShebang()

function! s:DetectVimlShebang() abort
  if did_filetype() || &filetype ==# 'vim'
    return
  endif
  let l:first = getline(1)
  if l:first =~# '^#!.*\<\%(vimlrs\|vim\|nvim\)\>'
    setfiletype vim
  endif
endfunction
