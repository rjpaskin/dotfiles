RSpec.describe "Javascript", role: "javascript" do
  describe "Neovim packages" do
    it "has JS-specific packages" do
      expect(neovim_packages).to include(
        "emmet-vim",
        "vim-javascript",
        "vim-jsx",
        "vim-prettier"
      )
    end
  end

  describe xdg_config_path("zsh/.zshrc") do
    it "has JS-specific Oh-My-ZSH plugins" do
      expect(oh_my_zsh_plugins).to include("node", "npm", "yarn")
    end

    it "loads nodenv" do
      aggregate_failures do
        expect(run_in_shell! "type nodenv").to include("is a shell function")
        expect(run_in_shell "nodenv --version").to be_success
      end
    end
  end

  describe xdg_config_path("yarn/global/package.json") do
    it { should be_a_file.and be_readable }
    it { should_not be_in_nix_store }
  end

  describe xdg_config_path("yarn/global/yarn.lock") do
    it { should be_a_file.and be_readable }
    it { should_not be_in_nix_store }
  end
end
