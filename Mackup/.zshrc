# Reset $PATH when we load tmux
# Avoids rbenv, nodenv etc. entries being added twice
if [ -n "$TMUX" ] && [ -x "/usr/libexec/path_helper" ]; then
  eval "$(PATH="" /usr/libexec/path_helper -s)"
fi

hash -d iCloud="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
hash -d dotfiles=~iCloud/dotfiles

source ~dotfiles/has_tag.sh

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment this to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment following line if you want to  shown in the command execution time stamp
# in the history command output. The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|
# yyyy-mm-dd
# HIST_STAMPS="mm/dd/yyyy"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git history-substring-search osx)

if has_tag "git_flow"; then plugins+=(git-flow); fi
# Don't use `rbenv` plugin as it messes up $PATH and $RBENV_ROOT,
# and otherwise only provides prompt info, which we don't use
if has_tag "ruby";     then plugins+=(bundler gem rails); fi
if has_tag "node";     then plugins+=(node npm yarn); fi
if has_tag "go";       then plugins+=(golang); fi
if has_tag "heroku";   then plugins+=(heroku); fi
if has_tag "docker";   then plugins+=(docker docker-compose); fi

source $ZSH/oh-my-zsh.sh

# User configuration
if has_tag "git_flow"; then alias gf="git flow"; fi # restore now-removed shortcut

if has_tag "ruby"; then
  local bcmd _eval

  # Don't try to run bundled commands in docker projects
  for bcmd in $bundled_commands; do
    read -d "" _eval <<EOF
      maybe_bundled_$bcmd() {
        setopt localoptions extendedglob

        if ! [ -z (../)#docker-compose.yml(N) ]; then
          unbundled_$bcmd
        else
          bundled_$bcmd
        fi
      }
EOF
    eval "$_eval"
    alias "$bcmd"="maybe_bundled_$bcmd"
  done
fi

# export PATH="/usr/local/bin:$PATH"
# export MANPATH="/usr/local/man:$MANPATH"

# # Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Tmuxinator completions
source /usr/local/share/zsh/site-functions/tmuxinator.zsh

# rbenv setup
if command -v rbenv >/dev/null; then
  eval "$(rbenv init - --no-rehash)"
fi

# nodenv setup
if command -v nodenv >/dev/null; then
  eval "$(nodenv init - --no-rehash)"
fi

# Golang setup
if command -v go >/dev/null; then
  export GOPATH="$HOME/src/golang"
fi

# Docker setup
if has_tag "docker"; then
  alias dup="docker-compose up"
  alias bdup="BYEBUG=1 docker-compose up"
  alias dkill="docker-compose kill"

  docker_compose_exec_when_up() {
    local service="$1"; shift

    until docker-compose ps "$service" 2> /dev/null | grep -i --silent "up"; do
      sleep 1
    done

    docker-compose exec "$service" "$@"
  }
fi
