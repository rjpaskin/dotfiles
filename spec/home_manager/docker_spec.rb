RSpec.describe "Docker", role: "docker" do
  describe xdg_config_path("zsh/.zshrc") do
    it "has Docker-specific Oh-My-ZSH plugins" do
      expect(oh_my_zsh_plugins).to include("docker", "docker-compose")
    end

    it "defines Docker-specific aliases" do
      aggregate_failures do
        expect(shell_aliases["dup"]).to eq("docker-compose up")
        expect(shell_aliases["bdup"]).to eq("BYEBUG=1 docker-compose up")
        expect(shell_aliases["dkill"]).to eq("docker-compose kill")
      end
    end
  end
end
