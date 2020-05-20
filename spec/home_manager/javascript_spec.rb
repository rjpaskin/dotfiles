RSpec.describe "Javascript", role: "javascript" do
  describe neovim_packages do
    it { should include("emmet-vim", "vim-javascript", "vim-jsx", "vim-prettier") }
  end

  describe oh_my_zsh_plugins do
    it { should include("node", "npm", "yarn") }
  end

  describe xdg_config_path("zsh/.zshrc") do
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
