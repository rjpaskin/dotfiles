RSpec.describe "Packages" do
  let(:nix_profile_manpath) { profile_path("share/man") }

  describe program("jq") do
    its(:location) { should eq profile_bin }
    its(:manpage) { should be_inside nix_profile_manpath }
    its("--version") { should be_success }

    it "runs without errors" do
      expect(run_in_shell! "echo '[]' | jq").to be_success
    end
  end
end
