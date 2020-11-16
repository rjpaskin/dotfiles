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

if brew list | grep --silent "qt@5.5"; then
  fancy_echo "Symlink qmake binary to /usr/local/bin for Capybara Webkit..."
  brew unlink qt@5.5
  brew link --force qt@5.5
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

atom_packages="$dotfiles_dir/atom/packages-list.txt"

if [ -f "$atom_packages" ]; then
  fancy_echo "Installing Atom packages ..."
  apm install --packages-file "$atom_packages"
fi

fancy_echo "All done!"
