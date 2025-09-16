RSpec.describe "Misc" do
  describe program("direnv") do
    its(:location) { should eq profile_bin }
    its("--version") { should be_success }

    it "is integrated into ZSH" do
      aggregate_failures do
        expect(shell_functions(:precmd)).to include("_direnv_hook")
        expect(shell_functions(:chpwd)).to include("_direnv_hook")
      end
    end

    describe xdg_config_path("direnv/direnvrc") do
      it { should be_a_file.and be_readable }

      it "overrides direnv_layout_dir()" do
        expect(subject).to include("direnv_layout_dir()")
      end

      describe xdg_config_path("direnv/lib/hm-nix-direnv.sh") do
        it { should be_a_file.and be_readable }
        it { should include("use_nix").and include("use_flake") }
      end
    end

    context "nix-direnv", skip: "Hangs" do
      using_tmpdir do |tmp|
        tmp.join(".envrc").write("use nix\n")
        tmp.join("shell.nix").write(<<~NIX)
          { pkgs ? (import <nixpkgs> {}) }:

          pkgs.mkShell {
            nativeBuildInputs = [ pkgs.which ];
          }
        NIX

        tmp.join("data").mkpath
        tmp.join("cache").mkpath
      end

      it "works with use_nix" do
        result = run_in_shell <<~SHELL
          export XDG_DATA_HOME=#{tmpdir}/data
          export XDG_CACHE_HOME=#{tmpdir}/cache
          direnv allow #{tmpdir}/.envrc
          cd #{tmpdir}
          echo $PATH
        SHELL

        aggregate_failures do
          expect(result).to be_success
          expect(result.stdout.as_search_path).to include(
            %r{^/nix/store/[^/]+-which-[^/]+/bin$}
          )
          expect(result.stderr).to include(/direnv: using nix/, /direnv: export.+\bPATH\b/)
        end
      end
    end
  end

  describe home_path(".bash_profile") do
    it { should be_a_file.and be_readable }
    it { should_not be_empty }
  end

  describe home_path(".bashrc") do
    it { should be_a_file.and be_readable }
    it { should_not be_empty }
  end

  describe xdg_data_path("bash/.keep") do
    it { should be_a_file }
  end

  describe home_path(".editorconfig") do
    it { should be_a_file.and be_readable }
    it { should include("trim_trailing_whitespace") }
  end

  describe home_path(".inputrc") do
    it { should be_a_file.and be_readable }
    it { should_not be_empty }
  end
end
