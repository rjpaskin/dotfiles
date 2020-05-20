RSpec.describe "Go", role: "go" do
  describe xdg_config_path("zsh/.zshrc") do
    it "has Go Oh-My-ZSH plugin" do
      expect(oh_my_zsh_plugins).to include("golang")
    end

    it "sets $GOPATH" do
      gopath = shell_variable("GOPATH")

      aggregate_failures do
        expect(gopath).to_not be_empty
        expect(path gopath).to be_a_directory.and be_readable
      end
    end
  end
end
