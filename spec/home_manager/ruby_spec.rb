RSpec.describe "Ruby", role: "ruby" do
  context "Neovim packages" do
    it "has Ruby-specific packages installed" do
      expect(neovim_packages).to include(
        *%w[
          splitjoin-vim
          vim-rails
          vim-endwise
          vim-ruby
          vim-rubyhash
          vim-yaml-helper
        ]
      )
    end
  end

  describe xdg_config_path("zsh/.zshrc") do
    it "has Ruby-specific Oh-My-ZSH plugins" do
      expect(oh_my_zsh_plugins).to include("bundler", "gem", "rails")
    end

    it "loads rbenv" do
      aggregate_failures do
        expect(run_in_shell! "type rbenv").to include("is a shell function")
        expect(run_in_shell "rbenv --version").to be_success
      end
    end

    it "overrides aliases from `bundler` Oh-My-ZSH plugin" do
      aggregate_failures do
        expect(shell_aliases["irb"]).to eq("maybe_bundled_irb")
        expect(shell_aliases["pry"]).to eq("maybe_bundled_pry")
        expect(shell_aliases["puma"]).to eq("maybe_bundled_puma")
        expect(shell_aliases["rackup"]).to eq("maybe_bundled_rackup")
        expect(shell_aliases["rake"]).to eq("maybe_bundled_rake")
        expect(shell_aliases["rspec"]).to eq("maybe_bundled_rspec")
        expect(shell_aliases["rubocop"]).to eq("maybe_bundled_rubocop")
        expect(shell_aliases["spring"]).to eq("maybe_bundled_spring")
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
end
