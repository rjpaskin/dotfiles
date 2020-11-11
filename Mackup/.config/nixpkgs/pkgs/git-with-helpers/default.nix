{ 
  lib,
  buildEnv, makeWrapper, runCommandLocal,
  writeScriptBin, writeShellScriptBin,
  git
}:

let
  gitGrep = flags: ''
    git branch -l${flags} --format="%(refname:short)" \
      | xargs git grep "$@"
  '';

  rename-branch = writeShellScriptBin "git-rename-branch" ''
    set -euo pipefail

    git branch -m "$1" "$2"
    git push origin ":$1"
    git push --set-upstream origin "$2"
  '';

  checkout-at = writeShellScriptBin "git-checkout-at" ''
    set -euo pipefail

    rev="$(git rev-list -1 --before="$1" ''${2:-master})"
    git checkout "$rev"
  '';

  oldest-ancestor = writeScriptBin "git-oldest-ancestor" ''
    #!/usr/bin/env zsh
    set -euo pipefail

    diff --old-line-format="" --new-line-format="" \
      <(git rev-list --first-parent "''${1:-master}") \
      <(git rev-list --first-parent "''${2:-HEAD}") | head -1' -"
  '';

  helpersPath = lib.makeBinPath [
    (writeShellScriptBin "git-grep-branch" (gitGrep "a"))
    (writeShellScriptBin "git-grep-branch-remote" (gitGrep "r"))
    (writeShellScriptBin "git-grep-branch-local" (gitGrep ""))
    rename-branch
    checkout-at
    oldest-ancestor
  ];

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
