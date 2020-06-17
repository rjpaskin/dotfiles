{ writeText, heroku, nodejs, buildEnv, makeWrapper, lib, stdenv }:

plugins:

let
  amendPackages = writeText "amendPackages.js" ''
    const fs = require("fs");
    const path = require("path");

    const pjson = JSON.parse(fs.readFileSync("./package.json"));
    const { pluginsToAdd, pluginsToRemove, topicsToRemove } = JSON.parse(process.argv[2]);

    pluginsToAdd.forEach(function({ packageName, version }) {
      pjson.oclif.plugins.push(packageName);

      // not needed for plugins to work it seems, but add it anyway
      pjson.dependencies[packageName] = version.toString();
    });

    pjson.oclif.plugins = pjson.oclif.plugins.filter(name => pluginsToRemove.indexOf(name) === -1)

    pluginsToRemove.forEach(function(packageName) {
      delete pjson.dependencies[packageName];
    });

    topicsToRemove.forEach(function(topic) {
      delete pjson.oclif.topics[topic];
    });

    fs.unlinkSync("./package.json"); // remove symlink
    fs.writeFileSync("./package.json", JSON.stringify(pjson, null, 2));
  '';

  pluginsAttrs = plugin: {
    inherit (plugin) packageName version;
  };

  pluginsJSON = builtins.toJSON {
    pluginsToAdd = (map pluginsAttrs plugins);
    pluginsToRemove = [
      "@oclif/plugin-warn-if-update-available"
      "@oclif/plugin-update"
    ];
    topicsToRemove = [ "update" ];
  };

  combined = buildEnv {
    name = "heroku-with-plugins-unwrapped-${heroku.version}";
    paths = [ "${heroku}/share/heroku" ] ++ map (drv: "${drv}/lib") plugins;
    buildInputs = [ makeWrapper ];

    postBuild = ''
      rm $out/bin # remove symlink
      mkdir $out/bin

      # Re-wrap bin so that it executes in the 'right' directory
      # to use our amended package.json
      cp ${heroku}/share/heroku/bin/run $out/bin/heroku
      wrapProgram $out/bin/heroku \
      --set HEROKU_DISABLE_AUTOUPDATE 1 \
      --set HEROKU_UPDATE_INSTRUCTIONS "" \
      --set HEROKU_SKIP_ANALYTICS 1

      cd $out
      ${nodejs}/bin/node ${amendPackages} ${lib.escapeShellArg pluginsJSON}
    '';
  };

in stdenv.mkDerivation {
  inherit (heroku) version;
  pname = "heroku-with-plugins";

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/share
    ln -s ${combined} $out/share/heroku
    ln -s ${combined}/bin $out/bin
  '';

  passthru = {
    inherit heroku plugins;
  };
}
