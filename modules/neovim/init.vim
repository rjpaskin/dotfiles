" -------------------------------------------------
"  Leader and shortcuts
" -------------------------------------------------
let g:mapleader = "\<space>"
let g:maplocalleader = ","

nnoremap <silent><leader>q :quit<cr>
nnoremap <silent><leader>w :write<cr>

" zoom current window
nnoremap <silent><leader>z :wincmd _<cr>:wincmd \|<cr>

" change to single quotes
nnoremap <leader>' :call PreserveWindowState("normal cs\"'")<CR>
" change to double quotes
nnoremap <leader>" :call PreserveWindowState("normal cs'\"")<CR>

function! PreserveWindowState(command)
  let w = winsaveview()
  execute a:command
  call winrestview(w)
endfunction

" Format entire file
nmap <leader>= :call PreserveWindowState("normal gg=G")<CR>

" Common typos
command! W w
command! Wq wq
command! WQ wq
command! Qa qa

augroup RJP
  " Clear out all existing autocmds in the augroup
  autocmd!
augroup END

" -------------------------------------------------
"  Core Settings
" -------------------------------------------------
set encoding=utf-8           " use UTF-8 encoding
set number                   " show line numbers
set relativenumber           " relative line numbers
set expandtab                " use spaces when <Tab> pressed
set shiftwidth=2             " number of spaces used by (auto)indent
set softtabstop=2            " how wide <Tab> is
set nobackup                 " disable backups
set nowritebackup            " disable backups
"set noswapfile              " disable swapfiles
set history=1000             " number of entries in the command history
set shortmess+=I             " suppress intro message
set splitright               " open vertical splits to the right
set splitbelow               " open horizontal splits below
set gdefault                 " replace all occurences on line without `g` flag, not just first one
set colorcolumn=             " disable coloured line at 80 chars
set showmatch                " show matching parentheses
set textwidth=0              " disable wrapping of text in insert mode
set diffopt+=vertical        " open diffs side-by-side by default
set diffopt+=iwhite          " ignore whitespace in diffs
set mouse=                   " disable mouse interaction in all modes
let &errorformat .=',%f'     " allow a list of (only) filenames to populate the quickfix list

if has("termguicolors")
  set termguicolors

  if exists('$TMUX')
    " Enable 24-bit ("true") colours
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  endif
endif

" Persistent undo
if has("persistent_undo")
  set undofile
endif

" -------------------------------------------------
" Syntax
" -------------------------------------------------
function! ClojureSetup()
  if g:clojure_special_indent_words !~ ",defui"
    let g:clojure_special_indent_words .= ',defui'
  endif
  let g:clojure_syntax_keywords = {
        \ 'clojureMacro': ["defproject", "defui", "deftest", "is", "testing"]
        \ }
endfunction

function! RubySetup()
  if exists('g:ruby_indent_assignment_style')
    let g:ruby_indent_assignment_style = 'variable'
  endif

  " Disable rubocop linting if not .rubocop.yml in $PWD
  if !filereadable(".rubocop.yml")
    let b:ale_linters = filter(
      \ copy(g:ale_linters["ruby"]), "!(v:val ==? 'rubocop')"
      \ )
      \ | ALELint
  endif
endfunction

augroup RJP
  autocmd FileType clojure :call ClojureSetup()
  autocmd FileType ruby :call RubySetup()
augroup END

" ------------------------------------------------
" Airline
" ------------------------------------------------
let g:airline_theme="one"
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'

function! AirlineInit()
  let g:airline_symbols.branch = ''
  let g:airline_symbols.linenr = ''
  let g:airline_symbols.maxlinenr = ''

  let g:airline_section_z = substitute(g:airline_section_z, '%3p%% ', '', '')
  let g:airline_section_z = substitute(g:airline_section_z, '%4l', '%l', '')
endfunction

augroup RJP
  autocmd User AirlineAfterInit call AirlineInit()
augroup END

" ------------------------------------------------
" The Silver Searcher
" ------------------------------------------------
if executable("ag")
  set grepprg=ag\ --vimgrep\ --hidden\ --path-to-ignore\ ~/.config/silver_searcher/ignore
endif

" bind K to grep word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" ------------------------------------------------
" EditorConfig
" ------------------------------------------------
" Prevent editorconfig interfering with fugitive
let g:EditorConfig_exclude_patterns = ["fugitive://.*"]

" Don't wrap over-long lines
let g:EditorConfig_disable_rules = ["max_line_length"]

" ------------------------------------------------
" SplitJoin
" ------------------------------------------------
" Don't indent multi-line args in line with opening `(`
let g:splitjoin_ruby_hanging_args = 0
" Don't use `{}` when joining/spliting hashes as last argument
let g:splitjoin_ruby_curly_braces = 0

" ------------------------------------------------
" vim-yaml-helper
" ------------------------------------------------
let g:vim_yaml_helper#auto_display_path = 1

" ------------------------------------------------
" RSpec.vim
" ------------------------------------------------
let g:rspec_command = "compiler rspec | Dispatch bin/rspec {spec}"

map <Leader>t :call RunCurrentSpecFile()<CR>
map <Leader>s :call RunNearestSpec()<CR>
map <Leader>l :call RunLastSpec()<CR>
map <Leader>a :call RunAllSpecs()<CR>

" From https://github.com/jferris/dotfiles/blob/master/vimrc.local
function! DockerSetup()
  if filereadable("docker-compose.yml")
    let g:rspec_command = "Dispatch docker-compose exec app bin/rspec {spec}"
    let g:dispatch_compilers["docker-compose exec app"] = "rspec"
  endif
endfunction

" Use `FileType ruby`?
augroup RJP
  autocmd BufNewFile,BufRead * :call DockerSetup()
augroup END

" ------------------------------------------------
" Rails.vim
" ------------------------------------------------
" Only set `eruby.yaml` filetype if file contains ERB tags
" (means that comment character is set correctly for normal YAML files)
augroup RJP
  autocmd FileType eruby.yaml
    \ if filereadable(expand("%:p")) && match(readfile(expand("%:p")), "<%") == -1 |
    \   set filetype=yaml |
    \ endif
augroup END

" ------------------------------------------------
" vim-prettier
" ------------------------------------------------
scriptencoding utf-32 " for vim-lint

let g:prettier#exec_cmd_async = 1
" Don't format code on save
let g:prettier#autoformat = 0

augroup RJP
  " autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql PrettierAsync
  autocmd BufWritePre */app/javascript/*.jsx,*/app/javascript/*.js PrettierAsync
augroup END

" max line length that prettier will wrap on
let g:prettier#config#print_width = 80
" number of spaces per indentation level
let g:prettier#config#tab_width = 4
" single quotes over double quotes
let g:prettier#config#single_quote = 'true'
" print spaces between brackets
let g:prettier#config#bracket_spacing = 'true'
" none|es5|all
let g:prettier#config#trailing_comma = 'none'

" ------------------------------------------------
" ALE
" ------------------------------------------------
let g:ale_linters = {
      \   'Dockerfile': ['hadolint'],
      \   'haml': ['haml_lint'],
      \   'javascript': ['eslint'],
      \   'jsx': ['eslint'],
      \   'ruby': ['rubocop'],
      \   'vim': ['vint'],
      \   'yaml': ['yamllint'],
      \ }

let g:ale_fixers = {
      \   'ruby': ['rubocop'],
      \ }

nnoremap <silent><C-n> :ALENext<cr>
nnoremap <silent><C-p> :ALEPrevious<cr>
nnoremap <silent><localleader>f   :ALEFix<cr>

let g:ale_sign_column_always = 1
let g:ale_sign_error = '••'
let g:ale_sign_warning = '••'

call one#highlight('ALEErrorSign', 'ca1243', 'fafafa', '')
call one#highlight('ALEError',     '',       'feeef2', '')

call one#highlight('ALEWarningSign', 'c18401', 'fafafa', '')
" lighter version of one's hue_5_2 (red 2)
call one#highlight('ALEWarning',     '',       'fff6e4', '')

let g:ale_echo_msg_format = '%linter%: %s'

augroup RJP
  autocmd FileType sh,javascript,javascript.jsx let b:ale_echo_msg_format = '%linter%%/code%: %s'
augroup END

let g:ale_sh_shellcheck_exclusions = 'SC2039' " comma-separated list

" ------------------------------------------------
" emmet-vim
" ------------------------------------------------
let g:user_emmet_leader_key='<c-e>'

let g:user_emmet_settings = {
\  'javascript.jsx' : {
\      'extends' : 'jsx',
\  },
\}

" For transient settings, debugging etc.
if filereadable($HOME . "/.config/nvim/tmp.vim")
  source ~/.config/nvim/tmp.vim
endif
