" vim-viml — indentation for VimL (Vimscript) buffers
"
" A standalone keyword-aware indenter for VimL's block grammar. Unlike AWK
" (brace-delimited), Vimscript opens and closes blocks with keywords, so this
" indents after a block-opening keyword (if / while / for / function / try),
" keeps block midpoints (elseif / else / catch / finally) one level out, and
" dedents the closing keywords (endif / endwhile / endfor / endfunction /
" endtry).

if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

setlocal autoindent
setlocal nolisp
setlocal nosmartindent
setlocal indentexpr=GetVimlIndent()
setlocal indentkeys=!^F,o,O,0=elseif,0=else,0=endif,0=endwhile,0=endfor,0=endfunction,0=endtry,0=catch,0=finally

let b:undo_indent = 'setlocal autoindent< lisp< smartindent< indentexpr< indentkeys<'

" Only define the function once.
if exists('*GetVimlIndent')
  finish
endif

function! GetVimlIndent() abort
  let l:prevlnum = prevnonblank(v:lnum - 1)
  if l:prevlnum == 0
    return 0
  endif

  " Strip a trailing command-position comment / a leading comment before
  " matching keywords, so block words inside strings/comments do not count.
  let l:prevline = getline(l:prevlnum)
  let l:curline  = getline(v:lnum)
  let l:ind = indent(l:prevlnum)
  let l:sw  = shiftwidth()

  " Indent one level deeper after a line that OPENS a block.
  if l:prevline =~# '\v^\s*%(fu%[nction]!?|if|elseif|else|while|for|try|catch|finally)>'
        \ && l:prevline !~# '\v<end%(function|if|while|for|try)>'
    let l:ind += l:sw
  endif

  " A block MIDPOINT (elseif / else / catch / finally) sits one level out from
  " its body — dedent it relative to the indent its opener just produced.
  if l:curline =~# '\v^\s*%(elseif|else|catch|finally)>'
    let l:ind -= l:sw
  endif

  " A block CLOSER (endif / endwhile / endfor / endfunction / endtry) dedents.
  if l:curline =~# '\v^\s*%(end%(if|while|for|function|try))>'
    let l:ind -= l:sw
  endif

  return l:ind < 0 ? 0 : l:ind
endfunction
