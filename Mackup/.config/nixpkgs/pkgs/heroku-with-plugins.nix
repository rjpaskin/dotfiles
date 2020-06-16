{ writeText, heroku, nodejs, buildEnv, makeWrapper, lib }:

plugins:

let
  addPluginsToPackage = writeText "addPluginsToPackage.js" ''
    const fs = require("fs");
    const path = require("path");

    const pjson = JSON.parse(fs.readFileSync("./package.json"));
    const plugins = JSON.parse(process.argv[2]);

    plugins.forEach(function({ packageName, version }) {
      pjson.oclif.plugins.push(packageName);

      // not needed for plugins to work it seems, but add it anyway
      pjson.dependencies[packageName] = version.toString();
    });

    fs.unlinkSync("./package.json"); // remove symlink
    fs.writeFileSync("./package.json", JSON.stringify(pjson, null, 2));
  '';

  pluginsAttrs = plugin: {
    inherit (plugin) packageName version;
  };

  pluginsJSON = builtins.toJSON (map pluginsAttrs plugins);

in buildEnv {
  name = "heroku-with-plugins";
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
    ${nodejs}/bin/node ${addPluginsToPackage} ${lib.escapeShellArg pluginsJSON}
  '';

  passthru = {
    inherit heroku plugins;
  };
}
