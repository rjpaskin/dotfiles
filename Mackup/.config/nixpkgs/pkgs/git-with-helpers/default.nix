{
  stdenv, lib,
  buildEnv, makeWrapper, runCommandLocal,
  git,
  fetchFromGitHub, fzf, ruby, writeShellScriptBin
}:

let
  helpersPath = lib.makeBinPath (
    builtins.attrValues (import ./helpers.nix {
      inherit stdenv lib fetchFromGitHub fzf ruby writeShellScriptBin;
    })
  );

  # We don't output a `git` file to avoid collisions with
  # the main `git` package - we could use `ignoreCollisions`
  # with `buildEnv`, but that would hide other collisions that
  # may break things
  wrappedGit = runCommandLocal "wrapped-git" {
    buildInputs = [ makeWrapper ];
  } ''
    mkdir -p $out/bin

    makeWrapper ${git}/bin/git $out/bin/git-wrapped \
      --set GIT_SSH /usr/bin/ssh \
      --prefix PATH : ${helpersPath}
  '';

in buildEnv {
  inherit (git) meta passthru;

  name = "git-with-helpers-${git.version}";
  paths = [ git wrappedGit ];
  buildInputs = [ makeWrapper ];

  postBuild = ''
    rm $out/bin/git
    mv $out/bin/git-wrapped $out/bin/git
  '';
}
