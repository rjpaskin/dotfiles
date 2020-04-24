#!/bin/sh

# Based on https://github.com/thoughtbot/laptop/blob/cf590e324a5067e06a21aa4f91bd0d214e09990d/mac

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\n==> $fmt\n" "$@"
}

# shellcheck disable=SC2154
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)
dotfiles_dir="$script_dir/.."

# shellcheck source=../has_tag.sh
. "$dotfiles_dir/has_tag.sh"

# set -x # for debugging

# From https://github.com/MikeMcQuaid/strap/blob/c72f36595f0f2160d017750a5e14f61825105731/bin/strap.sh
fancy_echo "Configuring security settings ..."
# Disable Java in Safari
defaults write com.apple.Safari \
  com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled \
  -bool false
defaults write com.apple.Safari \
  com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles \
  -bool false
# Ask for password as soon as screensaver loaded
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
# Enable firewall
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
sudo launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist 2>/dev/null

dir_is_in_path() {
  local dir="$1"

  [[ ":$PATH:" == *:"$dir":* ]]
}

update_shell() {
  local shell_path;
  shell_path="$(which zsh)"

  fancy_echo "Changing your shell to zsh ..."
  if ! grep --silent "$shell_path" /etc/shells; then
    fancy_echo "Adding '$shell_path' to /etc/shells"
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi
  sudo chsh -s "$shell_path" "$LOGNAME"
}

git_clone_or_pull() {
  local repo_url="$1"
  local local_repo="$2"

  if ! [ -d "$local_repo/.git" ]; then
    git clone --recursive "$repo_url" "$local_repo"
  else
    pushd "$local_repo" > /dev/null
    git pull "$repo_url" && git submodule update --init --recursive
    popd > /dev/null
  fi
}

github_clone_or_pull() {
  git_clone_or_pull "https://github.com/$1.git"  "$2"
}

download_or_update_file() {
  local filename="$1"; shift
  local url="$1"; shift
  local zflag=""

  if [ -e "$filename" ]; then zflag="-z $filename"; fi

  # shellcheck disable=SC2086
  curl -fsSL $zflag "$url" -o "$filename" "$@"
}

ensure_symlink() {
  local src="$1"
  local dest="$2"

  if ! [ -L "$dest" ]; then
    ln -siv "$src" "$dest"
  fi
}

get_user_email() {
  security find-generic-password -s com.apple.account.IdentityServices.token 2>/dev/null \
    | awk -F\" '{if ($2 == "acct") {print $4}}'
}

HOMEBREW_PREFIX="/usr/local"

sudo mkdir -p "$HOMEBREW_PREFIX"
sudo chflags norestricted "$HOMEBREW_PREFIX"

if ! command -v brew >/dev/null; then
  fancy_echo "Installing Homebrew ..."
  /usr/bin/ruby -e \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Ensure that Homebrew stuff (e.g. Ruby) is found first
# when installing formulae (e.g. Vim)
export PATH="/usr/local/bin:$PATH"

if [ -z "$SKIP_INSTALLS" ]; then
  fancy_echo "Updating Homebrew formulae ..."
  brew update --force # https://github.com/Homebrew/brew/issues/1151
  brew bundle check --no-upgrade --file="$script_dir/Brewfile" || brew bundle --verbose --file="$script_dir/Brewfile"
else
  fancy_echo "Skipping brew install"
fi

if has_tag "qt" && brew list | grep --silent "qt@5.5"; then
  fancy_echo "Symlink qmake binary to /usr/local/bin for Capybara Webkit..."
  brew unlink qt@5.5
  brew link --force qt@5.5
fi

if has_tag "heroku" && brew list | grep --silent "heroku"; then
  for plugin in "heroku-repo" "heroku-accounts"; do
    if heroku plugins | grep --silent "$plugin"; then
      heroku plugins:install "$plugin"
    fi
  done

  fancy_echo "Setup Heroku with: heroku accounts:add <home|work>, then: heroku accounts:set <home|work>"
fi

case "$SHELL" in
  */zsh)
    if [ "$(which zsh)" != '/usr/local/bin/zsh' ] ; then
      update_shell
    fi
    ;;
  *)
    update_shell
    ;;
esac

fancy_echo "Downloading/updating oh-my-zsh ..."
github_clone_or_pull "robbyrussell/oh-my-zsh" "$HOME/.oh-my-zsh"

if has_tag "ruby"; then
  fancy_echo "Configuring Ruby ..."

  if ! dir_is_in_path "$HOME/.rbenv/shims"; then
    # shellcheck disable=SC2016
    eval "$(rbenv init -)"
  fi

  if [ -z "$SKIP_INSTALLS" ]; then
    find_latest_ruby() {
      rbenv install --list | grep -v '-' | tail -1 | sed -e 's/^ *//'
    }

    ruby_version="$(find_latest_ruby)"

    if ! rbenv versions | grep -Fq "$ruby_version"; then
      RUBY_CONFIGURE_OPTS=--with-openssl-dir=/usr/local/opt/openssl \
        rbenv install --skip-existing "$ruby_version"
    fi

    rbenv global "$ruby_version"
    rbenv shell "$ruby_version"
  else
    fancy_echo "Skipping installing latest ruby version"
  fi

  gem update --system

  number_of_cores=$(sysctl -n hw.ncpu)
  bundle config --global jobs $((number_of_cores - 1))
fi

if has_tag "node"; then
  fancy_echo "Configuring Node ..."

  if ! dir_is_in_path "$HOME/.nodenv/shims"; then
    # shellcheck disable=SC2016
    eval "$(nodenv init -)"
  fi

  if [ -z "$SKIP_INSTALLS" ]; then
    find_latest_node() {
      nodenv install --list | grep -vE '(-|nightly|rc)' | tail -1 | sed -e 's/^ *//'
    }

    node_version="$(find_latest_node)"

    if ! nodenv versions 2> /dev/null | grep -Fq "$node_version"; then
      NODE_CONFIGURE_OPTS=--with-openssl-dir=/usr/local/opt/openssl \
        nodenv install --skip-existing "$node_version"
    fi

    nodenv global "$node_version"
    nodenv shell "$node_version"
  else
    fancy_echo "Skipping installing latest node version"
  fi
fi

if ! [ -f "$HOME/.ssh/id_rsa" ]; then
  fancy_echo "Generating a new SSH key ..."
  ssh_password=$(openssl rand -base64 18 | tee "$HOME/Desktop/ssh_key.txt")
  ssh-keygen -t rsa -b 4096 -C "$(get_user_email)" -N "$ssh_password"

  eval "$(ssh-agent -s)"

  # Ensure default macOS program is used, so that the passphrase is stored in
  # the macOS Keychain
  /usr/bin/ssh-add -K "$HOME/.ssh/id_rsa"

  fancy_echo 'Add ~/Desktop/ssh_key.txt to your password manager (and delete the file)'
  fancy_echo 'Add your key to GitHub: pbcopy < ~/.ssh/id_rsa.pub'
fi

atom_packages="$dotfiles_dir/Mackup/.atom/packages-list.txt"

if [ -f "$atom_packages" ]; then
  fancy_echo "Installing Atom packages ..."
  apm install --packages-file "$atom_packages"
fi

fancy_echo "Restoring dotfiles with Mackup ..."
# bootstrap Mackup config
ensure_symlink "$dotfiles_dir/Mackup/.mackup.cfg" "$HOME/.mackup.cfg"
ensure_symlink "$dotfiles_dir/Mackup/.mackup" "$HOME/.mackup"

mackup restore

fancy_echo "Symlinking \`bin\` directory to \$HOME ..."
ensure_symlink "$dotfiles_dir/bin" "$HOME/.bin"

fancy_echo "All done!"
