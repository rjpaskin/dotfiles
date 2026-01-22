# Dotfiles

Uses:

- [Nix](https://nixos.org) for dotfiles, CLI tool and general system config, via:
  - [Home Manager](https://github.com/nix-community/home-manager)
  - [nix-darwin](https://github.com/nix-darwin/nix-darwin)
- [Homebrew][brew] for GUI apps
- [Chezmoi](https://www.chezmoi.io) for private or host-specific config

## One-time Setup

> [!NOTE]
> At one point these were automated, but they only need to be done once when setting up a new computer, and frequently change with the OS version, so it's easier to just do them manually

1. Install Determinate Nix (see [website](https://determinate.systems/))
2. Install Homebrew (see [website][brew])

[1]: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
[brew]: https://brew.sh

Now run:

```sh
# Assuming that $PWD is this repo
$ sudo nix run .#rebuild -- switch --flake $PWD#<hostname>

# if that doesn't work, try:
$ sudo nix run --inputs-from $PWD nix-darwin#darwin-rebuild -- switch --flake $PWD#<hostname>
```

Next steps:

1. Create SSH key (see GH's [docs][1] for current recommendation):
   1. Add to [GitHub](https://github.com/settings/keys)
   2. Add to SSH agent (again, see GH's [docs][1])
2. Remap Caps Lock to Ctrl on all keyboards (via System Settings)

```sh
# Set computer name
$ read '?Hostname: ' name; for var in ComputerName HostName LocalHostName; do sudo scutil --set "$var" "$name"; done

# Set default location for `darwin-rebuild` `--flake` option
$ sudo ln -ivs ~/src/dotfiles/flake.nix /etc/nix-darwin/flake.nix

# Setup Chezmoi
$ ln -ivs ~/src/dotfiles ~/.local/share/chezmoi
$ mkdir -p ~/.config/chezmoi
$ ln -ivs ~/src/dotfiles/hosts/chezmoi/$(hostname).toml ~/.config/chezmoi/chezmoi.toml

# Run Chezmoi
$ chezmoi diff
# (check output, then)
$ chezmoi apply
```
