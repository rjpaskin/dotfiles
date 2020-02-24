# Add colours to ls and grep
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
export GREP_OPTIONS='--color=auto'

export MANPATH=`manpath`:/usr/local/man

# Customise command prompt
export PS1="\e[7m pwd: \w \e[0m\n\[$(tput bold)\]\u@\h: \$ \[$(tput sgr0)\]"

# Shell settings
shopt -s cdspell      # corrects typos in `cd`
shopt -s checkwinsize # resize ouput to fit window
export IGNOREEOF=1    # Ctrl+D must be pressed twice to exit shell

# History settings
export HISTCONTROL=ignoreboth # don't put duplicate lines or empty spaces in the history
shopt -s cmdhist    # combine multiline commands in history
shopt -s histappend # merge session histories

# General system aliases
alias ..='cd ..'

# Directory listings
alias ll='ls -lh'   # list files in long format w/ human-readable filesizes
alias la='ls -alh'  # list all files, incl. hidden
alias ld='ls -d */' # list directories within current directory
alias lt='ls -lht'  # list files, sorted by time modified
alias lfs='ls -lhS' # list files, sorted by size
alias lr='ls -lhR'  # list files recursively
alias l1='ls -1'    # list files, forcing 1 entry per line

# Make destructive operations prompt by default
alias rm='rm -i'
alias srm='srm -iv'
alias cp='cp -i'
alias mv='mv -i'

alias finder_hidden_show='defaults write com.apple.finder AppleShowAllFiles TRUE; killall Finder'
alias finder_hidden_hide='defaults write com.apple.finder AppleShowAllFiles FALSE; killall Finder'

alias b='edit ~/.bash_profile'
alias reload='source ~/.bash_profile'

alias size='du -hsc'    # display human-readable filesize, with entry for each file and a grand total at the end
alias size-af='du -hca' # display human-readable filesizes (including directories) recursively, with a grand total at the end
alias size-ad='du -hc'  # display human-readable directory sizes recursively, with a grand total at the end

# Program aliases
alias diff-brief='diff --brief'
alias f='find . -iname'   # find a filename
alias sqlite='sqlite3'
alias vlc='open -a VLC'

# Directory aliases
alias desk='cd ~/Desktop'
alias doc='cd ~/Documents'
alias sites='cd ~/Sites'

# Prefer MAMP executables
#export PATH="/Applications/MAMP/Library/bin:/Applications/MAMP/bin/php/php5.3.14/bin:$PATH"

alias cdb='cd ~/Documents/Projects/cdb && edit . && open -a Safari http://cdb.dev'

# Git completion (requires Homebrew)
if [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ]; then
  . `brew --prefix`/etc/bash_completion.d/git-completion.bash
fi

# Setup rbenv
if ! command -v rbenv >/dev/null; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi
