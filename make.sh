#!/bin/bash

############################
# This script symlinks from the home dir to my dotfiles
############################

### Variables

# Dotfiles dir
dir=~/dotfiles

# list of files/folders to symlink in homedir
files="tmux.conf bashrc vimrc vim zshrc oh-my-zsh gitignore" 

### Script

# Remove old old dotfiles dir in case some cuck is rerunning
rm -rf $olddir

# change to the dotfiles directory
cd $dir

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 
for file in $files; do
    echo "Deleting old $file"
    rm -rf ~/.$file
    echo "Creating symlink to $file in home directory."
    ln -s $dir/dots/$file ~/.$file
done

echo "Updating submodules"
git submodule update --init
echo "...done"
