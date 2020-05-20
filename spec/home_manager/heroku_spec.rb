RSpec.describe "Heroku", role: "heroku" do
  describe oh_my_zsh_plugins do
    it { should include("heroku") }
  end
end
