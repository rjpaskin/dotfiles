RSpec.describe "Ruby", role: "ruby" do
  describe neovim_packages do
    it { should include("splitjoin-vim", "vim-rails", "vim-endwise",
                        "vim-ruby", "vim-rubyhash", "vim-yaml-helper") }
  end

  describe oh_my_zsh_plugins do
    it { should include("gem", "rails") }
    it { should_not include("bundler") }
  end

  describe shell_variable("FPATH") do
    it { should include(%r{share/oh-my-zsh/plugins/bundler$}) }
  end

  describe xdg_config_path("zsh/.zshrc") do
    it "loads rbenv" do
      aggregate_failures do
        expect(run_in_shell! "type rbenv").to include("is a shell function")
        expect(run_in_shell "rbenv --version").to be_success
      end
    end
  end

  describe home_path(".gemrc") do
    it { should be_a_file.and be_readable }
  end

  describe home_path(".irbrc") do
    it { should be_a_file.and be_readable }
  end

  describe home_path(".rbenv/default-gems") do
    it { should be_a_file.and be_readable }
  end

  describe program("mailcatcher"), role: "mailcatcher" do
    its(:location) { should eq profile_bin }
  end

  describe program("ultrahook"), role: "ultrahook" do
    its(:location) { should eq profile_bin }
  end
end
