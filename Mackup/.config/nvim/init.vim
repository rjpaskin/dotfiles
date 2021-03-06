set nocompatible

" -------------------------------------------------
"  Leader and shortcuts
" -------------------------------------------------
let g:mapleader = "\<space>"
let g:maplocalleader = "\<NUL>" " Ctrl+Space

nnoremap <silent><leader>q :quit<cr>
nnoremap <silent><leader>w :write<cr>

" zoom current window
nnoremap <silent><leader>z :wincmd _<cr>:wincmd \|<cr>

inoremap jj <esc>
inoremap jk <esc>

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
"  Plugins
" -------------------------------------------------
call plug#begin()

" Sensible defaults
Plug 'tpope/vim-sensible'

" Add commenting
Plug 'tpope/vim-commentary'
" Add 'surround' motion
Plug 'tpope/vim-surround'
" Enable `.` for additional commands
Plug 'tpope/vim-repeat'
" Paired commands with ']' and `[`
Plug 'tpope/vim-unimpaired'
" Case-aware substition and case transformations
Plug 'tpope/vim-abolish'
" Asynchronously execute processes
Plug 'tpope/vim-dispatch'
" Shell command helpers
Plug 'tpope/vim-eunuch'
" Alias Ex commands
Plug 'Konfekt/vim-alias'
" Mkdir automatatically when saving
Plug 'pbrisbin/vim-mkdir'
" Better search highlight behaviour
Plug 'junegunn/vim-slash'

" Navigate between vim and tmux splits
Plug 'christoomey/vim-tmux-navigator'

" Custom text objects (base for other plugins)
Plug 'kana/vim-textobj-user'
" `(i|a)r` for Ruby blocks
Plug 'nelstrom/vim-textobj-rubyblock'
" `(i|a)v` for underscored/camel-cased parts of words
Plug 'Julian/vim-textobj-variable-segment'

" https://github.com/adriaanzon/vim-textobj-matchit " more generic version of vim-textobj-rubyblock
" https://github.com/tek/vim-textobj-ruby " can include blank after block

" Autocomplete
Plug 'Shougo/deoplete.nvim', { 'tag': '5.1', 'do': ':UpdateRemotePlugins \| !pip3 install --user \"msgpack=0.6.2\"' }

" Configurable status bar
Plug 'vim-airline/vim-airline'

" Latest runtime files for Ruby
Plug 'vim-ruby/vim-ruby'
" Automatically add `end` to Ruby blocks
Plug 'tpope/vim-endwise'
" Refactorings for Ruby
Plug 'ecomba/vim-ruby-refactoring'
" Split/join lines of code
Plug 'AndrewRadev/splitjoin.vim'
" Convert to Ruby 1.9 hash syntax, or between string/symbol keys
Plug 'rorymckinley/vim-rubyhash'
" Brewfile syntax
Plug 'bfontaine/Brewfile.vim'

" Project navigation
Plug 'Shougo/denite.nvim', { 'tag': '2.1' }
" MRU files plugin for Denite
Plug 'Shougo/neomru.vim'
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'

" Git integration
Plug 'tpope/vim-fugitive'
" GitHub extension for fugitive.vim
Plug 'tpope/vim-rhubarb'

Plug 'editorconfig/editorconfig-vim'

" Rails
Plug 'tpope/vim-rbenv'
Plug 'tpope/vim-bundler'
Plug 'tpope/vim-rails'
" Replace with janko-m/vim-test?
Plug 'thoughtbot/vim-rspec'

" Javascript
Plug 'pangloss/vim-Javascript'
Plug 'mxw/vim-jsx'
Plug 'mattn/emmet-vim'
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }

" Linting
Plug 'w0rp/ale'

" YAML
Plug 'lmeijvogel/vim-yaml-helper'

" Clojure
Plug 'tpope/vim-salve'
Plug 'tpope/vim-fireplace'
Plug 'guns/vim-sexp'
Plug 'tpope/vim-sexp-mappings-for-regular-people'

" Colour scheme
Plug 'rakr/vim-one'

call plug#end()

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
set shell=/usr/local/bin/zsh
set colorcolumn=             " disable coloured line at 80 chars
set showmatch                " show matching parentheses
set textwidth=0              " disable wrapping of text in insert mode
set diffopt+=vertical        " open diffs side-by-side by default
set diffopt+=iwhite          " ignore whitespace in diffs
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

let g:ruby_host_prog = '~/.rbenv/versions/2.7.0/bin/neovim-ruby-host'

" -------------------------------------------------
" Colour scheme
" -------------------------------------------------
colorscheme one
set background=light

" https://stackoverflow.com/questions/1467438/find-out-to-which-highlight-group-a-particular-keyword-symbol-belongs-in-vim
call one#highlight('Normal',      '', 'ffffff', '')
call one#highlight('ColorColumn', '', 'ffffff', '')
" Replace grey background with lighter version of foreground (http://www.0to255.com)
call one#highlight('DiffAdded',   '', 'f5faf5', '')
call one#highlight('DiffRemoved', '', 'fcedec', '')
call one#highlight('DiffLine',    '', 'eff4fe', '')

call one#highlight('DiffNewFile', '', 'ffffff', 'bold')
call one#highlight('DiffFile',    '', 'ffffff', 'bold')

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

" -------------------------------------------------
" Denite
" -------------------------------------------------
" Prevent undo being triggered when we mess up the key sequence
nnoremap <silent><leader>u  :Denite -buffer-name=file_rec file/rec<cr>

nnoremap <silent><leader>uu :Denite -buffer-name=file_rec file/rec<cr>
nnoremap <silent><leader>ub :Denite -buffer-name=buffers  buffer<cr>
nnoremap <silent><leader>ul :Denite -buffer-name=line     line<cr>
nnoremap <silent><leader>uo :Denite -buffer-name=outline  outline<cr>
nnoremap <silent><leader>ur :Denite -buffer-name=register register<cr>
nnoremap <silent><leader>uff :Denite -buffer-name=file_mru file_mru<cr>

nnoremap <silent><leader>up               :Denite -buffer-name=current_directory
      \ -path=`expand('%:p:h')`
      \ file/rec<cr>

" Rails-specific
nnoremap <silent><leader>um               :Denite -buffer-name=models
      \ -path=`getcwd()`/app/models
      \ file/rec<cr>
nnoremap <silent><leader>uc               :Denite -buffer-name=controllers
      \ -path=`getcwd()`/app/controllers
      \ file/rec<cr>
nnoremap <silent><leader>uv               :Denite -buffer-name=views
      \ -path=`getcwd()`/app/views
      \ file/rec<cr>
nnoremap <silent><leader>uh               :Denite -buffer-name=helpers
      \ -path=`getcwd()`/app/helpers
      \ file/rec<cr>
nnoremap <silent><leader>uw               :Denite -buffer-name=workers
      \ -path=`getcwd()`/app/workers
      \ file/rec<cr>
nnoremap <silent><leader>uj               :Denite -buffer-name=javascripts
      \ -source-names=hide
      \ file/rec:`getcwd()`/app/javascript
      \ file/rec:`getcwd()`/app/assets/javascripts<cr>
nnoremap <silent><leader>us               :Denite -buffer-name=specs
      \ -path=`getcwd()`/spec
      \ file/rec<cr>
nnoremap <silent><leader>uf               :Denite -buffer-name=factories
      \ -path=`getcwd()`/spec/support/factories
      \ file/rec<cr>

" Char that matches search query
call one#highlight('rjp_denite_matched_char',  'c18401', 'fff6e4', '')
" Range of non-matching chars between two matching chars
call one#highlight('rjp_denite_matched_range', '222222', 'fff6e4', '')
" Selected row in Denite's 'Insert' mode
call one#highlight('rjp_denite_insert_mode',   'ffffff', '4078f2', '')
" Selected row in Denite's 'Normal' mode
call one#highlight('rjp_denite_normal_mode',   'ffffff', '50a14f', '')

call denite#custom#option('_', {
      \ 'highlight_matched_char': 'rjp_denite_matched_char',
      \ 'highlight_matched_range': 'rjp_denite_matched_range',
      \ 'highlight_mode_insert': 'rjp_denite_insert_mode',
      \ 'highlight_mode_normal': 'rjp_denite_normal_mode',
      \ })

call denite#custom#var('file/rec', 'command', [
    \ 'ag', '--follow', '--nocolor', '--nogroup',
    \ '--hidden', '--path-to-ignore', '~/.config/silver_searcher/ignore', '-g', ''])

" ------------------------------------------------
" Deoplete
" ------------------------------------------------
let g:deoplete#enable_at_startup = 1

" Ensure Deoplete doesn't crash due to https://github.com/vim/vim/issues/3117
if has('python3')
  silent! python3 1
endif

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" Use <TAB> to cycle through completions
inoremap <silent><expr> <TAB>
  \ pumvisible() ?
    \ "\<C-n>" :
    \ <SID>check_back_space() ? "\<TAB>" : deoplete#mappings#manual_complete()

" Use <shift-TAB> to cycle through completions
inoremap <silent><expr> <S-TAB>
  \ pumvisible() ? "\<C-p>" : "\<S-TAB>"

" inoremap <silent><expr> <Esc>pumvisible() ? "\<C-e>" : "\<Esc>"

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
" NERDtree
" ------------------------------------------------
map <Leader>n <plug>NERDTreeTabsToggle<CR>
map <Leader>nf :NERDTreeFind<CR>

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
" vim-jsx
" ------------------------------------------------
let g:jsx_ext_required = 0

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
" flow|babylon|typescript|postcss|json|graphql
let g:prettier#config#parser = 'flow'

" ------------------------------------------------
" ALE
" ------------------------------------------------
let g:ale_linters = {
      \   'Dockerfile': ['hadolint'],
      \   'haml': ['haml_lint'],
      \   'javascript': ['eslint', 'flow'],
      \   'jsx': ['eslint', 'flow'],
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
