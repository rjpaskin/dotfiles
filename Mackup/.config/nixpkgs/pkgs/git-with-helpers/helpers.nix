{
  stdenv, lib,
  writeShellScriptBin
}:

let
  gitGrep = { flags ? "", suffix ? null }: let
    name = [ "git-grep-branch" ] ++ (lib.lists.optional (suffix != null) suffix);
  in writeShellScriptBin (builtins.concatStringsSep "-" name) ''
    git branch -l${flags} --format="%(refname:short)" \
      | xargs git grep "$@"
  '';

in {
  checkout-at = writeShellScriptBin "git-checkout-at" ''
    set -euo pipefail

    rev="$(git rev-list -1 --before="$1" ''${2:-master})"
    git checkout "$rev"
  '';

  grep-branch = gitGrep { flags = "a"; };
  grep-branch-local = gitGrep { suffix = "local"; };
  grep-branch-remote = gitGrep { suffix = "remote"; flags = "a"; };

  oldest-ancestor = writeShellScriptBin "git-oldest-ancestor" ''
    set -euo pipefail

    diff --old-line-format="" --new-line-format="" \
      <(git rev-list --first-parent "''${1:-master}") \
      <(git rev-list --first-parent "''${2:-HEAD}") | head -1
  '';

  rename-branch = writeShellScriptBin "git-rename-branch" ''
    set -euo pipefail

    git branch -m "$1" "$2"
    git push origin ":$1"
    git push --set-upstream origin "$2"
  '';
}
