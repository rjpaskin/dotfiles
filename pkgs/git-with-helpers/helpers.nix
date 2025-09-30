{
  stdenv, lib,
  fetchFromGitHub, writeShellScriptBin, writeTextFile,
  fzf, ruby,
  ...
}:

let
  gitGrep = { flags ? "", suffix ? null }: let
    name = [ "git-grep-branch" ] ++ (lib.lists.optional (suffix != null) suffix);
  in writeShellScriptBin (builtins.concatStringsSep "-" name) ''
    git branch -l${flags} --format="%(refname:short)" \
      | xargs git grep "$@"
  '';

  mkBinPackage = { name, src, path ? name, ... }@args: stdenv.mkDerivation ({
    phases = [ "unpackPhase" "buildPhase" "fixupPhase" ];
    dontStrip = true;
    buildPhase = ''
      mkdir -p $out/bin
      cp "$src/${path}" $out/bin
    '';
  } // removeAttrs args [ "path" ]);

in {
  checkout-at = writeShellScriptBin "git-checkout-at" ''
    set -euo pipefail

    rev="$(git rev-list -1 --before="$1" ''${2:-master})"
    git checkout "$rev"
  '';

  co = writeShellScriptBin "git-co" ''
    if [ "$#" -gt 0 ]; then exec git checkout "$@"; fi

    fzf="fzf"

    command -v tmux > /dev/null && fzf="fzf-tmux"

    ref="$(
      git show-ref |
      sed -e "s|.* refs/||" -e "s|heads/||" |
      "${fzf}/bin/$fzf" |
      sed -e "s|remotes/origin/||" -e "s|tags/||"
    )"

    [ -n "$ref" ] && git checkout "$ref"
  '';

  ffwd = mkBinPackage rec {
    name = "git-ffwd";
    path = "bin/${name}";
    src = fetchFromGitHub {
      owner = "muhqu";
      repo = "dotfiles";
      rev = "97f20c81860bc84de412dbdf9b3d8b37b89bc770";
      sha256 = "1hr0p66bz4wmsv7qsrqwx85rs00wqzbxc8n2bd7h2wxylwhrn7p0";
    };
    postFixup = ''
      # Fix deprecated flag
      sed -e "s|git branch -l|git branch --create-reflog|" -i $out/${path}
    '';
  };

  grep-branch = gitGrep { flags = "a"; };
  grep-branch-local = gitGrep { suffix = "local"; };
  grep-branch-remote = gitGrep { suffix = "remote"; flags = "a"; };

  mv-with-history = mkBinPackage {
    name = "git-mv-with-history";
    src = fetchFromGitHub {
      githubBase = "gist.github.com";
      owner = "ilanKeshet";
      repo = "bf4251b21919d341cf4431f89e77a8a5";
      rev = "d90bf2bcb75fe6c521105545b95234471f7f9e8d";
      sha256 = "07mxi2fdix5qp4884fzc607998v2lnc8i0czcm1zxcjgix93ldm6";
    };
  };

  merge-rails-schema = stdenv.mkDerivation {
    name = "merge-rails-schema";
    src = builtins.readFile ./merge-rails-schema;
    phases = [ "buildPhase" "fixupPhase" ];
    buildInputs = [ ruby ];
    dontStrip = true;
    buildPhase = ''
      mkdir -p $out/bin
      echo "$src" > $out/bin/$name

      chmod +x $out/bin/$name
      patchShebangs --build $out/bin
    '';
  };

  oldest-ancestor = writeShellScriptBin "git-oldest-ancestor" ''
    set -euo pipefail

    diff --old-line-format="" --new-line-format="" \
      <(git rev-list --first-parent "''${1:-master}") \
      <(git rev-list --first-parent "''${2:-HEAD}") | head -1
  '';

  recreate-branch = writeShellScriptBin "git-recreate-branch" ''
    set -euo pipefail

    base_branch="''${1:-master}"
    branch_to_move="''${2:-$(git symbolic-ref --short HEAD)}"

    echo "Moving $branch_to_move onto $base_branch"

    new_commits_count=$(git rev-list --count "$branch_to_move".."$base_branch")

    if [ "$new_commits_count" -eq 0 ]; then
      # move branch
      git checkout "$branch_to_move"
      git checkout "$base_branch"
      git pull
      git branch -D "$branch_to_move"
      git checkout -b "$branch_to_move"
    else
      git rebase --onto "$base_branch" "$base_branch" "$branch_to_move"
    fi
  '';

  rename-branch = writeShellScriptBin "git-rename-branch" ''
    set -euo pipefail

    git branch -m "$1" "$2"
    git push origin ":$1"
    git push --set-upstream origin "$2"
  '';

  stash-rename = writeShellScriptBin "git-stash-rename" ''
    rev="$(git rev-parse "$1")" && git stash drop "$1" || exit 1

    git diff-index --quiet HEAD; s="$?"
    [ "$s" != 0 ] && git stash save "tmp stash from stash-rename"

    git stash apply "$rev" && shift && git stash save "$@" \
      && [ "$s" != 0 ] && git stash pop "stash@{1}"
  '';
}
