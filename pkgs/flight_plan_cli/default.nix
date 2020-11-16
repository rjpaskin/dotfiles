{ bundlerApp, ruby }:

bundlerApp {
  inherit ruby;
  pname = "flight_plan_cli";
  gemdir = ./.;
  exes = [ "flight" ];
}
