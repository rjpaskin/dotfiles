RSpec.describe "Packages" do
  let(:nix_profile_manpath) { profile_path("share/man") }

  describe program("ag") do
    its(:location) { should eq profile_bin }
    its(:manpage) { should be_inside nix_profile_manpath }

    let(:needle) { "string for ag to find" }

    it "runs without errors" do
      result = run_in_shell!("ag --vimgrep '#{needle}' '#{File.dirname __FILE__}'")

      expect(result).to include(__FILE__, needle)
    end

    describe xdg_config_path("silver_searcher/ignore") do
      it { should be_a_file.and be_readable }
      it { should include(".git") }
    end

    describe shell_alias("ag") do
      it { should eq("ag --hidden --path-to-ignore ~/.config/silver_searcher/ignore") }
    end
  end

  describe program("ctags") do
    its(:location) { should eq profile_bin }
    its("--version") { should include(/universal ctags/i) }
    its(:manpage) { should be_inside nix_profile_manpath }

    class ClassForCtagsToIndex; end

    it "runs without errors" do
      result = run_in_shell("ctags -f - '#{__FILE__}'")

      aggregate_failures do
        expect(result).to be_success
        expect(result.stdout).to include(__FILE__, "ClassForCtagsToIndex")
        expect(result.stderr).to be_empty
      end
    end

    describe xdg_config_path("ctags/config.ctags") do
      it { should be_a_file.and be_readable }
      it { should include(/--exclude=node_modules/) }
    end

    describe xdg_config_path("ctags/nix.ctags") do
      it { should be_a_file.and be_readable }
      it { should include(/--langdef=Nix/i) }
    end

    it "loads config files without warnings" do
      expect(command! "ctags --list-languages").to be_success.and include("Nix")
    end
  end

  describe program("fzf") do
    its(:location) { should eq profile_bin }
    its(:manpage) { should be_inside nix_profile_manpath }
    its("--version") { should be_success }
  end

  describe program("fzf-tmux") do
    its(:location) { should eq profile_bin }
  end

  describe program("jq") do
    its(:location) { should eq profile_bin }
    its(:manpage) { should be_inside nix_profile_manpath }
    its("--version") { should be_success }

    it "runs without errors" do
      expect(run_in_shell! "echo '[]' | jq").to be_success
    end
  end

  describe program("shellcheck") do
    its(:location) { should eq profile_bin }
    its(:manpage) { should be_inside nix_profile_manpath }

    it "runs without errors" do
      result = run_in_shell("echo 'ls $1' | shellcheck -s sh -f gcc -")

      aggregate_failures do
        expect(result.status).to eq(1)
        expect(result.stdout).to include("[SC2086]")
      end
    end
  end

  describe program("ncdu") do
    its(:location) { should eq profile_bin }
    its(:manpage) { should be_inside nix_profile_manpath }
    its("--version") { should be_success }
  end

  describe program("flight"), role: "flight-plan" do
    its(:location) { should eq profile_bin }

    it "runs without errors" do
      result = run_in_shell("flight help")

      aggregate_failures do
        expect(result).to be_success
        expect(result.stdout).to include(/flight.?plan/i)
        expect(result.stderr).to be_empty
      end
    end
  end

  describe program("autoterm") do
    its(:location) { should eq profile_bin }
  end

  describe program("aws") do
    its(:location) { should eq profile_bin }
    its("--version") { should be_success }

    it { should include(%r{export PATH=\S*/nix/store/[^/]+-session-manager-plugin-[^/]+/bin}) }

    describe xdg_config_path("zsh/.zshrc") do
      it { should include("source $HOME/.nix-profile/share/zsh/site-functions/aws_zsh_completer.sh") }
    end
  end
end
