RSpec.describe "Heroku", role: "heroku" do
  describe program("heroku") do
    its(:location) { should eq nix_profile_bin }
    its("--version") { should be_success.and include("heroku") }
  end

  describe oh_my_zsh_plugins do
    it { should include("heroku") }
  end
end
