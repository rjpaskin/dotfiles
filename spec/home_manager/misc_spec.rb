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

      it "loads nix-direnv" do
        expect(subject).to include(%r{^source .+/nix-direnv/direnvrc})
      end

      it "overrides direnv_layout_dir()" do
        expect(subject).to include("direnv_layout_dir()")
      end
    end

    context "nix-direnv" do
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

  describe home_path(".ssh/config") do
    it { should be_a_file.and be_readable }
    it { should include(/^\s+UseKeychain\s+yes/) }
  end

  context "emacs" do
    describe file("/Applications/Emacs.app") do
      it { should exist }
    end

    %w[elpa quelpa].each do |pkg_directory|
      describe home_path(".emacs.d/#{pkg_directory}") do
        it { should be_a_directory.and be_readable }
        it { should_not be_empty }
        its(:realpath) { should be_inside(icloud_path) }
      end
    end

    describe home_path(".emacs.d") do
      it { should be_a_directory.and be_writable }
    end

    describe home_path(".emacs.d/init.el") do
      it { should be_a_file.and be_readable }
    end

    describe home_path(".emacs.d/custom.el") do
      it { should be_a_file }
      its(:realpath) { should be_writable }
    end
  end
end
