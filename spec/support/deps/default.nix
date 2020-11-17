with (import ../../..).nixpkgs;

bundlerEnv {
  ruby = ruby_2_6;
  name = "dotfiles-specs";
  gemdir = ./.;
}
