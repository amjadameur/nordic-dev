#!/usr/bin/env bash

trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h|--help] [--param]

Nordic environment for dev: gnome, vim, tmux, git, zsh and more.

Available options:

-h, --help	Print this help and exit
--terminal	Nordic GNOME Terminal	
--gtk		Nordic GNOME GTK
--zsh		Nordic ZSH
--bash		Nordic BASH
--vim		Nordic VIM
--tmux		Nordic TMUX
--git		Nordic GIT

All are installed if no options passed.
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

PKG_ITER="0"

nordic_log_start() {
    PKG_ITER=$((PKG_ITER+1))
    msg "${CYAN}[${PKG_ITER}/${N_PKGS}] Nordic: ${1} installing!${NOFORMAT}"
}

nordic_log_end() {
    msg "${GREEN}[${PKG_ITER}/${N_PKGS}] Nordic: ${1} installed!${NOFORMAT}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  NORDIC_TERMINAL=''
  NORDIC_GTK=''
  NORDIC_ZSH=''
  NORDIC_BASH=''
  NORDIC_VIM=''
  NORDIC_TMUX=''
  NORDIC_GIT=''
  N_PKGS="1"
  args=("$@")

  if [[ ${#args[@]} -eq 0 ]]; then
    NORDIC_TERMINAL=1
    NORDIC_GTK=1
    NORDIC_ZSH=1
    NORDIC_BASH=1
    NORDIC_VIM=1
    NORDIC_TMUX=1
    NORDIC_GIT=1
    N_PKGS="8"
    return;
  fi

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    --terminal) NORDIC_TERMINAL=1 ;;
    --gtk) NORDIC_GTK=1 ;;
    --zsh) NORDIC_ZSH=1 ;;
    --bash) NORDIC_BASH=1 ;;
    --vim) NORDIC_VIM=1 ;;
    --tmux) NORDIC_TMUX=1 ;;
    --git) NORDIC_GIT=1 ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    N_PKGS=$((N_PKGS+1))
    shift
  done

  return 0
}

show_params() {
    # script logic here
    msg "${CYAN}Read parameters:${NOFORMAT}"
    msg "${ORANGE}- terminal: ${NORDIC_TERMINAL}"
    msg "- gtk: ${NORDIC_GTK}"
    msg "- zsh: ${NORDIC_ZSH}"
    msg "- bash: ${NORDIC_BASH}"
    msg "- vim: ${NORDIC_VIM}"
    msg "- tmux: ${NORDIC_TMUX}"
    msg "- git: ${NORDIC_GIT}"
    msg "${NOFORMAT}"
}

nordic_requirements() {
    nordic_log_start "requirements"

    sudo apt update -y
    sudo apt install -y git-core curl ripgrep fd-find

    mkdir -p $HOME/.local/bin/; ln -s $(which fdfind) ~/.local/bin/fd

    nordic_log_end "requirements"
}

nordic_terminal() {
    nordic_log_start "terminal"

    sudo apt-get install -y gnome-terminal

    git clone https://github.com/nordtheme/gnome-terminal.git ${SETUP_DIR}/gnome-terminal
    pushd ${SETUP_DIR}/gnome-terminal/src
    ./nord.sh
    popd

    # Dumped with:
    # dconf dump /org/gnome/terminal/legacy/keybindings/ > gnome-terminal-keybindings.dconf
    # dconf dump /org/gnome/terminal/legacy/profiles:/ > gnome-terminal-profiles.dconf
    dconf load /org/gnome/terminal/legacy/profiles:/ < configs/gnome-terminal-profiles.dconf
    dconf load /org/gnome/terminal/legacy/keybindings/ < configs/gnome-terminal-keybindings.dconf

    nordic_log_end "terminal"
}

nordic_gtk() {
    nordic_log_start "gtk"

    sudo snap install gnome-extension-manager

    # Gnome extensions
    mkdir -p ~/.local/share/gnome-shell/extensions/
    cp -rf configs/gnome-shell/extensions/* ~/.local/share/gnome-shell/extensions/

    # Gnome Nordic Theme 
    pushd ${SETUP_DIR}/ &&
    wget -O nordic-gtk.zip https://github.com/EliverLara/Nordic/archive/refs/heads/master.zip && \
    unzip -o nordic-gtk.zip && \
    mkdir -p ~/.themes && \
    cp -r Nordic-master ~/.themes && \
    gsettings set org.gnome.desktop.interface gtk-theme "Nordic-master" && \
    gsettings set org.gnome.desktop.wm.preferences theme "Nordic-master" && \
    popd

    # Gnome Nordic Icons
    mkdir -p ~/.icons
    cp -r configs/icons/* ~/.icons
    gsettings set org.gnome.desktop.interface icon-theme 'Nordic-darker'

    # Gnome Nordic Fonts
    gsettings set org.gnome.desktop.interface document-font-name 'Roboto Mono for Powerline 11'
    gsettings set org.gnome.desktop.interface font-name 'Roboto Mono for Powerline 11'
    gsettings set org.gnome.desktop.interface monospace-font-name 'Roboto Mono for Powerline 13'

    nordic_log_end "gtk"
}

nordic_vim() {
    nordic_log_start "vim"

    sudo apt install -y vim python3-pip
    pip3 install --user powerline-status
    sudo apt install -y fonts-powerline
    sudo apt install -y cscope

    local POWERLINE_VIM=`find  $HOME/.local/lib/python*/site-packages/powerline/bindings -type d -name "vim"`

    # Vim plugging manager
    mkdir -p ~/.vim/bundle/
    mkdir -p ~/.vim/plugin/
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

    # Cscope vim plugging
    wget https://raw.githubusercontent.com/joe-skb7/cscope-maps/master/plugin/cscope_maps.vim -O $HOME/.vim/plugin/cscope_maps.vim

    cp configs/.vimrc $HOME/.vimrc
    echo "set rtp+=${POWERLINE_VIM}/" >> $HOME/.vimrc

    vim +PluginInstall +qall

    nordic_log_end "vim"
}

nordic_tmux() {
    nordic_log_start "tmux"

    sudo apt install -y tmux

    cp configs/.tmux.conf $HOME/.tmux.conf

    # Install TPM pluggin manager
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    ~/.tmux/plugins/tpm/scripts/install_plugins.sh

    nordic_log_end "tmux"
}

nordic_bash() {
    nordic_log_start "bash"

    cp configs/.userrc $HOME/.userrc
    cat configs/.bashrc >> $HOME/.bashrc

    nordic_log_end "bash"
}

nordic_zsh() {
    nordic_log_start "zsh"

    sudo apt install -y zsh

    # Zsh terminal profile
    git clone https://github.com/pixegami/terminal-profile.git ${SETUP_DIR}/terminal-profile
    pushd ${SETUP_DIR}/terminal-profile

    # Don't switch to zsh in the script
    sed '/chsh \-s/d' -i install_profile.sh

    # Install Patched Font installed by powerline
    mkdir ~/.fonts
    sudo cp -a fonts/. ~/.fonts/
    fc-cache -vf ~/.fonts/

    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" --unattended
    ./install_profile.sh
    popd

    cp configs/.userrc $HOME/.userrc
    cp configs/.zshrc $HOME/.zshrc

    nordic_log_end "zsh"
}

nordic_git() {
    nordic_log_start "git"

    cp configs/.gitconfig $HOME/.gitconfig

    nordic_log_end "git"
}

main() {
    SETUP_DIR="$HOME/env"
    mkdir -p ${SETUP_DIR}

    nordic_requirements
    [[ ${NORDIC_TERMINAL} -eq 1 ]] && nordic_terminal
    [[ ${NORDIC_GTK} -eq 1 ]] && nordic_gtk
    [[ ${NORDIC_ZSH} -eq 1 ]] && nordic_zsh
    [[ ${NORDIC_BASH} -eq 1 ]] && nordic_bash
    [[ ${NORDIC_VIM} -eq 1 ]] && nordic_vim
    [[ ${NORDIC_TMUX} -eq 1 ]] && nordic_tmux
    [[ ${NORDIC_GIT} -eq 1 ]] && nordic_git
}

setup_colors
parse_params "$@"
show_params
main
