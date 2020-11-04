RSpec.describe "Javascript", role: "javascript" do
  describe program("node") do
    its(:location) { should eq profile_bin }
  end

  describe program("npm") do
    its(:location) { should eq profile_bin }
  end

  describe program("yarn") do
    its(:location) { should eq profile_bin }
  end

  describe neovim_packages do
    it { should include("emmet-vim", "vim-javascript", "vim-jsx-pretty", "vim-prettier") }
  end

  describe oh_my_zsh_plugins do
    it { should include("node", "npm", "yarn") }
  end
end
