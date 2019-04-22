#!/bin/bash

############################
# Heavily inspired by https://github.com/stek29/dotfiles and https://github.com/nicksp/dotfiles
############################

### Variables

# Dotfiles dir
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd -P)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

dir=~/dotfiles                        # dotfiles directory
dir_backup=~/dotfiles-old             # old dotfiles backup directory

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export DOTFILES_DIR

### Utils
ask_for_confirmation() {
  while true; do
    read -p "$(print_question "$1")" yn
    case $yn in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo "Please answer yes or no.";;
    esac
  done
  unset yn
}

ask_for_sudo() {
  # Ask for the administrator password upfront
  sudo -v

  # Update existing `sudo` time stamp until this script has finished
  # https://gist.github.com/cowboy/3118588
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done &> /dev/null &
}

print_log() {
  printf "$1"
  printf "$1" |\
    sed "s/\x1B\[\([0-9]\{1,2\}\(;[0-9]\{1,2\}\)\?\)\?[mGK]//g"\
    >>setup.log
}

execute() {
  eval $1 >>setup.log 2>&1
  print_result $? "${2:-$1}"
}

print_error() {
  # Print output in red
  print_log "\e[0;31m  [✖] $1 $2\e[0m\n"
}

print_info() {
  # Print output in purple
  print_log "\e[0;35m  $1\e[0m\n"
}

print_question() {
  # Print output in yellow
  print_log "\e[0;33m  [?] $1\e[0m"
}

print_result() {
  [ $1 -eq 0 ] \
    && print_success "$2" \
    || print_error "$2"

  [[ "$3" == "true" ]] && [ $1 -ne 0 ] \
    && exit
}

print_success() {
  # Print output in green
  print_log "\e[0;32m  [✔] $1\e[0m\n"
}

mklink() {
  local sourceFile="$1"
  local targetFile="$2"
  local backupToDir="$3"

  if [ -d "$backupToDir" ]; then
    backupTo="$backupToDir/$(basename "$targetFile")"
  fi

  if [ ! -e "$targetFile" ]; then
    execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
  elif [[ "$(readlink "$targetFile")" == "$sourceFile" ]]; then
    print_success "$targetFile → $sourceFile"
  else
    if [ ! -z "$backupTo" ]; then
      print_success "Backup'd $targetFile → $backupTo"
      execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
    elif ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"; then
      rm -r "$targetFile"
      execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
    else
      print_error "$targetFile → $sourceFile"
    fi
  fi
}

recursive_link() {
  for f in $1/*; do
    fname="$(basename "$f")"
    if [ \! -L "$2/$fname" -a -d "$2/$fname" -a -d "$f" ]; then
      # dir to dir
      recursive_link "$f" "$2/$fname"
    else
      mklink "$f" "$2/$fname"
    fi
  done
}

# empty logfile
: >'setup.log'

if ask_for_confirmation "Install pkgs (brew, cask, mas)?"; then
  if [ "$(uname)" = "Darwin" ]; then
    if ! type "brew" >/dev/null; then
      print_error "No homebrew found, skipping"
    else
      execute "brew tap Homebrew/bundle"
      execute "brew bundle --file=packages/Brewfile" "Homebrew & Cask & Mac App Store"
    fi
  fi
fi

# Create dotfiles_old in homedir
print_info "Creating $dir_backup for backup of existing dotfiles in ~"
mkdir -p $dir_backup

cd $dir

# Fetch submodules
print_info "Fetching submodules"
git submodule update --quiet --init --recursive
print_result $? "Submodules fetched"

# list of files/folders to symlink in homedir
FILES=(
 "dots/tmux.conf"
 "dots/bashrc"
 "dots/zshrc" 
 "dots/gitignore"
)

# move any existing dotfiles in homedir to ~/dotfiles-old directory, then create symlinks 
for i in ${FILES[@]}; do
  sourceFile="$PWD/$i"
  targetFile="$HOME/.$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"
  mklink "$sourceFile" "$targetFile" "$dir_backup"
done

unset FILES

# Install vundle
mkdir -p $HOME/.vim
mklink $DOTFILES_DIR/dots/vimrc $HOME/.vim/vimrc
if test \! -d $HOME/.vim/bundle/Vundle.vim/.git; then
  print_info "Installing Vundle"
  git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
fi

# nvim
ln -fs $HOME/.vim $HOME/.config/nvim
ln -fs vimrc $HOME/.vim/init.vim

print_info "Updating Vundle plugins..."
vim +PluginUpdate +qall >/dev/null 2>&1
print_result $? "Updated"

# Oh My Zsh
if [ -z "$ZSH_CUSTOM" ]; then
  ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
fi
mklink ~/dotfiles/dots/oh-my-zsh ~/.oh-my-zsh
mklink "~/dotfiles/zsh-custom" "$ZSH_CUSTOM"
