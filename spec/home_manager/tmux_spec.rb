RSpec.describe "Tmux" do
  describe xdg_config_path("zsh/.zshrc") do
    it { should include(%r{maybe_source .+/tmuxinator.zsh}) }
  end

  describe home_path(".tmux.conf") do
    it { should be_a_file.and be_readable }
    it { should_not be_blank }
  end

  describe home_path(".tmuxinator") do
    it { should be_a_directory.and be_readable }

    it "contains YAML config files" do
      expect(subject.glob "*.yml").to_not be_empty
    end
  end

  describe home_path(".tmuxinator/default_helper.rb") do
    it { should be_a_file.and be_readable }
  end
end
