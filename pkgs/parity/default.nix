{ bundlerApp, ruby }:

bundlerApp {
  inherit ruby;

  pname = "parity";
  exes = [ "development" "staging" "production" "pr_app" ];
  gemdir = ./.;
}
