" vim-viml — syntax highlighting for the VimL (Vimscript) language (vimlrs)
"
" A standalone Vimscript grammar covering the eval-engine surface vimlrs
" implements (a Rust port of Neovim's eval engine on fusevm): statement
" keywords, common ex commands, scope-sigil variables (g:/s:/b:/…), option /
" env / register sigils, the special v: vars, the ported builtin-function
" subset, both string-quote forms, numbers, and command-position comments.
" Everything links to standard highlight groups, so every colorscheme covers
" it.
"
" This AUGMENTS / overrides Vim's built-in `vim` filetype syntax (intended): we
" want the vimlrs builtin subset and tooling story, not the stock runtime file.
"
" Verified against vimlrs 0.1.0 — Neovim eval engine port (fusevm).

if exists('b:current_syntax')
  finish
endif

syntax case match
syntax sync minlines=50

" ---------------------------------------------------------------------------
" Comments / shebang
" ---------------------------------------------------------------------------
" VimL's classic ambiguity: a `"` is a comment ONLY in command position (line
" start, or after a `|` bar); in expression position it opens a double-quoted
" string. We handle this pragmatically the way Vim's own runtime syntax does —
" the overwhelmingly common case is a full-line comment `^\s*"...` — and let
" the vimString region claim a `"` that opens a double-quoted string elsewhere.
syntax keyword vimTodo contained TODO FIXME XXX NOTE HACK
syntax match   vimComment "^\s*\".*$" contains=vimTodo,@Spell
syntax match   vimComment "\s\+\"[^"]*$" contains=vimTodo,@Spell
syntax match   vimShebang "\%^#!.*$"

" ---------------------------------------------------------------------------
" Numbers
" ---------------------------------------------------------------------------
syntax match vimNumber "\<\d\+\>"
syntax match vimNumber "\<0[xX]\x\+\>"
syntax match vimFloat  "\<\d\+\.\d*\%([eE][-+]\?\d\+\)\?\>"
syntax match vimFloat  "\<\d\+[eE][-+]\?\d\+\>"

" ---------------------------------------------------------------------------
" Strings
" ---------------------------------------------------------------------------
" Single-quoted strings are literal (no backslash escapes; '' is a literal ').
syntax region vimSingleQuote start=+'+ skip=+''+ end=+'+ oneline
" Double-quoted strings honor backslash escapes.
syntax match  vimStringEscape contained "\\."
syntax region vimString start=+"+ skip=+\\"+ end=+"+ oneline contains=vimStringEscape,@Spell

" ---------------------------------------------------------------------------
" Scope-sigil variables, options, env vars, registers
" ---------------------------------------------------------------------------
" Namespaced scopes: g:global s:script b:buffer w:window t:tab l:local
" a:arg v:vim. Highlight the whole `scope:name` token.
syntax match vimScopeVar "\<[gsbwtlav]:\h\w*"
" Bare scope sigil (e.g. `for k in keys(g:)`).
syntax match vimScopeVar "\<[gsbwtlav]:"
" Options: &name &l:name &g:name ; env vars: $NAME ; registers: @x
syntax match vimOption   "&\%([gl]:\)\?\h\w*"
syntax match vimEnvVar   "\$\h\w*"
syntax match vimRegister "@[-\"0-9a-zA-Z*+:.%#=/]"

" Special v: variables vimlrs exposes.
syntax keyword vimSpecialVar v:true v:false v:null v:none v:count v:count1
syntax keyword vimSpecialVar v:version v:val v:key v:exception v:throwpoint
syntax keyword vimSpecialVar v:lnum v:errmsg v:shell_error v:this_session
syntax keyword vimSpecialVar v:char v:register v:servername

" ---------------------------------------------------------------------------
" Keywords — statements & control flow
" ---------------------------------------------------------------------------
syntax keyword vimStatement if elseif else endif while endwhile for endfor in
syntax keyword vimStatement function endfunction return break continue
syntax keyword vimStatement try catch finally throw finish
syntax keyword vimStatement let unlet const lockvar unlockvar
syntax keyword vimStatement call eval execute echo echon echohl echomsg echoerr
syntax keyword vimStatement echowindow

" ---------------------------------------------------------------------------
" Common ex commands
" ---------------------------------------------------------------------------
syntax keyword vimExCommand source runtime normal redir silent verbose
syntax keyword vimExCommand set setlocal setglobal command delcommand
syntax keyword vimExCommand autocmd augroup highlight syntax sign sleep
syntax keyword vimExCommand map nmap imap vmap xmap noremap nnoremap inoremap
syntax keyword vimExCommand vnoremap xnoremap cnoremap abbreviate

" ---------------------------------------------------------------------------
" Built-in functions (vimlrs's ported funcs.c subset)
" ---------------------------------------------------------------------------
" Conversion / type / list / dict / string / math / system — the curated
" subset the vimlrs runtime ports from Neovim's funcs.c.
syntax keyword vimFunction abs add and append argc call ceil char2nr copy cos
syntax keyword vimFunction count deepcopy empty escape eval execute exists
syntax keyword vimFunction extend filter float2nr floor fmod fnameescape
syntax keyword vimFunction function get getenv getpid has has_key index input
syntax keyword vimFunction insert invert isinf isnan items join json_decode
syntax keyword vimFunction json_encode keys len line localtime map match
syntax keyword vimFunction matchstr max min nr2char or pathshorten pow printf
syntax keyword vimFunction rand range reduce reltime reltimefloat reltimestr
syntax keyword vimFunction remove repeat reverse round setenv sha256
syntax keyword vimFunction shellescape sin sort soundfold split sqrt srand
syntax keyword vimFunction str2float str2nr strcharpart strftime string strlen
syntax keyword vimFunction strpart strptime strridx strtrans submatch
syntax keyword vimFunction substitute tolower toupper trim type values xor
syntax keyword vimFunction flatten flattennew list2blob blob2list

" ---------------------------------------------------------------------------
" Operators
" ---------------------------------------------------------------------------
syntax match vimOperator "+\|-\|\*\|/\|%"
syntax match vimOperator "\.\.\|\."
syntax match vimOperator "==\|!=\|<=\|>=\|<\|>\|=\~\|!\~"
syntax match vimOperator "&&\|||\|!"
syntax match vimOperator "=\|+=\|-=\|\*=\|/=\|%=\|\.="
syntax match vimOperator "?\|:"

" ---------------------------------------------------------------------------
" Highlight links
" ---------------------------------------------------------------------------
highlight default link vimComment       Comment
highlight default link vimShebang       PreProc
highlight default link vimTodo          Todo
highlight default link vimNumber        Number
highlight default link vimFloat         Float
highlight default link vimString        String
highlight default link vimSingleQuote   String
highlight default link vimStringEscape  SpecialChar
highlight default link vimScopeVar      Identifier
highlight default link vimOption        Special
highlight default link vimEnvVar        Special
highlight default link vimRegister      Special
highlight default link vimSpecialVar    Constant
highlight default link vimStatement     Statement
highlight default link vimExCommand     PreProc
highlight default link vimFunction      Function
highlight default link vimOperator      Operator

let b:current_syntax = 'vim'
