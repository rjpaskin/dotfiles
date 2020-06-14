RSpec.describe "Ruby", role: "ruby" do
  describe program("ruby") do
    its(:location) { should eq profile_bin }
  end

  describe program("irb") do
    its(:location) { should eq profile_bin }
  end

  describe program("gem") do
    its(:location) { should eq profile_bin }
  end

  xdescribe program("rake") do
    its(:location) { should eq profile_bin }
  end

  describe "gem `byebug`" do
    it "is installed with default Ruby package" do
      result = command("#{profile_bin "ruby"} -rbyebug -e exit")

      aggregate_failures do
        expect(result).to be_success
        expect(result.stderr).to be_empty
      end
    end
  end

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

  describe home_path(".gemrc") do
    it { should be_a_file.and be_readable }
    its(:contents) { should include("--no-document") }
  end

  describe home_path(".irbrc") do
    it { should be_a_file.and be_readable }
  end

  describe program("mailcatcher"), role: "mailcatcher" do
    its(:location) { should eq profile_bin }
  end

  describe program("ultrahook"), role: "ultrahook" do
    its(:location) { should eq profile_bin }
  end

  describe program("rubocop"), role: "rubocop" do
    its(:location) { should eq profile_bin }
    its("--version") { should start_with "0.59" }
  end
end
