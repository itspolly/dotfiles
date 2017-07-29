# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# -------------------------------------------------------------------
# General ZSH config
# -------------------------------------------------------------------

ZSH_THEME="dracula"
plugins=(git)

source $ZSH/oh-my-zsh.sh

# -------------------------------------------------------------------
# Git
# -------------------------------------------------------------------

alias ga='git add'
alias gp='git push'
alias gl='git log'
alias gs='git status'
alias gd='git diff'
alias gm='git commit -m'
alias gma='git commit -am'
alias gb='git branch'
alias gc='git checkout'
alias gra='git remote add'
alias grr='git remote rm'
alias gpu='git pull'
alias gcl='git clone'
alias gta='git tag -a -m'
alias gf='git reflog'
alias gs='git status'

# -------------------------------------------------------------------
# Useful Functions
# -------------------------------------------------------------------

# Upload a file to transfer.sh
function transfer() { if [ $# -eq 0 ]; then echo -e "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"; return 1; fi 
tmpfile=$( mktemp -t transferXXX ); if tty -s; then basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g'); curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile; else curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile ; fi; cat $tmpfile; rm -f $tmpfile; } 

# Serve the current folder
alias serve="python -c 'import SimpleHTTPServer; SimpleHTTPServer.test()'"

# Show & Hide hidden files in macOS finder
function hiddenOn() { defaults write com.apple.Finder AppleShowAllFiles YES ; }
function hiddenOff() { defaults write com.apple.Finder AppleShowAllFiles NO ; }

# Get my (public) IP
function pubip() {
    echo -n "Current External IP: "
    curl icanhazip.com
}

# Get local IPs
function localip() {
    ifconfig | grep "inet " | awk '{ print $2 }'
}

# Get battery status
function battery_status() {
  if [[ $(sysctl -n hw.model) == *"Book"* ]]
  then
    $ZSH/bin/battery-status
  fi
}


# -------------------------------------------------------------------
# Aliases
# -------------------------------------------------------------------

# ----
# Development
# ----

alias ios="open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app"
alias watchos="open /Applications/Xcode.app/Contents/Developer/Applications/Simulator\ \(Watch\).app"


# -------------------------------------------------------------------
# User configuration
# -------------------------------------------------------------------

# Setup NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# I'm a brit, yo.
export LANG=en_GB.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vim'
fi
