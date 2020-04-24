{ lib, ... }@args:

with lib;

let
  dag = lib.hm.dag;

  homeDir = "/Users/${builtins.getEnv "LOGNAME"}/Desktop/hm-test-home";

  wrap = var: value: scriptName: let
    varName = "$" + var;
  in {
    "${scriptName}Set${var}" = dag.entryBefore [scriptName] ''
      set -x
      export __RJP_TO_RESET_${var}="${varName}"
      export ${var}="${value}"
      set +x
    '';

    "${scriptName}Reset${var}" = dag.entryAfter [scriptName] ''
      set -x
      export ${var}="$__RJP_TO_RESET_${var}"
      unset __RJP_TO_RESET_${var}
      set +x
    '';
  };

  wrapWithHome = wrap "HOME" homeDir;

in {
  home = {
    activation = foldl' (out: item: out // wrapWithHome item) {} [
      "checkLinkTargets"
      "linkGeneration"
      "onFilesChange"
    ];

    homeDirectory = homeDir;
  };
}
