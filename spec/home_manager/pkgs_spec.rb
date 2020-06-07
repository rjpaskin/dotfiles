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

  describe program("jq") do
    its(:location) { should eq profile_bin }
    its(:manpage) { should be_inside nix_profile_manpath }
    its("--version") { should be_success }

    it "runs without errors" do
      expect(run_in_shell! "echo '[]' | jq").to be_success
    end
  end
end
