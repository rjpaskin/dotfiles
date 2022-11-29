with (import ../../..).nixpkgs;

bundlerEnv {
  ruby = ruby_2_7;
  name = "dotfiles-specs";
  gemdir = ./.;
}
