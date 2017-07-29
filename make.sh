#!/bin/bash

############################
# This script symlinks from the home dir to my dotfiles
############################

### Variables

# Dotfiles dir
dir=~/dotfiles

#Old dotfiles backup directory
olddir=~/dotfiles_old 

# list of files/folders to symlink in homedir
files="bashrc vimrc vim zshrc oh-my-zsh gitignore" 

### Script

# Remove old old dotfiles dir in case some cuck is rerunning
rm -rf $olddir

# create dotfiles_old in homedir
mkdir -p $olddir

# change to the dotfiles directory
cd $dir

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 
for file in $files; do
    echo "Moving old $file from ~ to $olddir"
    mv ~/.$file ~/dotfiles_old/
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/.$file
done

# update vim submodules
echo "Updating vim submodules"
cd ~/dotfiles/vim
git submodule update --init
echo "...done"
