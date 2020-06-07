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
        expect(result.stderr.strip).to be_empty
      end
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
end
