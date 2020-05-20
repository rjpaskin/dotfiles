RSpec.describe "Heroku", role: "heroku" do
  describe xdg_config_path("zsh/.zshrc") do
    it "has Heroku Oh-My-ZSH plugin" do
      expect(oh_my_zsh_plugins).to include("heroku")
    end
  end
end
