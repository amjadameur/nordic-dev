set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'preservim/nerdtree'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'preservim/vimux'
Plugin 'timakro/vim-copytoggle'
call vundle#end()

filetype plugin indent on

syntax on

let g:tmux_navigator_disable_when_zoomed = 1


set ruler
set ignorecase
set hlsearch

" Rendered tab
set softtabstop=8

" Actual tab width
set tabstop=8
set shiftwidth=8

" Show tabs, F3 to toggle view
set list
set lcs=tab:\|\  " the last character is space!
nmap <F3> <Plug>copytoggle

set mouse=a

nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>

" Always show statusline
set laststatus=2

" Use 256 colours (Use this setting only if your terminal supports 256 colours)
set t_Co=256

" Always show the command as it is being typed.
set showcmd

set splitbelow
set splitright
