{ symlinkJoin, makeWrapper, heroku }:

symlinkJoin {
  name = "heroku-with-plugins";
  paths = [ heroku ];

  plugins = [ "repo" "accounts" ];

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    mkdir -p "$out/plugins"

    for plugin in $plugins; do
      HEROKU_DATA_DIR=$out/plugins \
        ${heroku}/bin/heroku plugins:install "$plugin"
    done

    wrapProgram $out/bin/heroku \
      --set HEROKU_DATA_DIR $out/plugins
  '';
}
