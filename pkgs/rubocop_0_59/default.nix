{ bundlerApp, ruby }:

bundlerApp {
  inherit ruby;

  pname = "rubocop";
  exes = [ "rubocop" ];
  gemdir = ./.;
}
