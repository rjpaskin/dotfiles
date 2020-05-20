RSpec.describe "Git", role: "git" do
  context "Neovim packages" do
    it "has Git-specific packages installed" do
      expect(neovim_packages).to include("vim-fugitive", "vim-rhubarb")
    end
  end

  describe xdg_config_path("zsh/.zshrc") do
    it "has Git Oh-My-ZSH plugin" do
      expect(oh_my_zsh_plugins).to include("git")
    end
  end

  describe xdg_config_path("git/attributes") do
    it { should be_a_file.and be_readable }

    it "sets up merge driver for `schema.rb`" do
      expect(subject.lines).to include("db/schema.rb merge=railsschema")
    end
  end

  describe xdg_config_path("git/ignore") do
    it { should be_a_file.and be_readable }
  end

  describe xdg_config_path("git/config") do
    it { should be_a_file.and be_readable }

    it "defines user details" do
      aggregate_failures do
        expect(git_config[:user][:email]).to_not be_empty
        expect(git_config[:user][:name]).to_not be_empty
      end
    end

    it "defines some basic settings" do
      aggregate_failures do
        expect(git_config[:core][:editor]).to eq("nvim")
        expect(git_config[:color][:ui]).to eq(true)
        expect(git_config[:rerere]).to include(enabled: true, autoupdate: true)
      end
    end

    it "defines some aliases" do
      aliases = git_config[:alias]

      aggregate_failures do
        expect(aliases[:up]).to include("git fetch", "git ffwd")
        expect(aliases[:branches]).to include("for-each-ref")
      end
    end

    it "defines merge driver for `schema.rb`" do
      aggregate_failures do
        expect(git_config[:merge]).to have_key(:railsschema)

        expect(git_config[:merge][:railsschema][:name]).not_to be_empty
        expect(git_config[:merge][:railsschema][:driver]).to eq(
          "merge-rails-schema %O %A %B %L"
        )
      end
    end
  end

  describe xdg_config_path("git/config.local") do
    it { should be_a_file.and be_readable }
  end

  describe home_path("Library/Application Support/SourceTree/sourcetree.license") do
    it { should be_a_file.and be_readable }

    it { should_not be_in_nix_store }
  end

  context "Git flow", role: "git-flow" do
    describe xdg_config_path("zsh/.zshrc") do
      it "has Git-Flow Oh-My-ZSH plugin" do
        expect(oh_my_zsh_plugins).to include("git-flow")
      end

      it "has git-flow alias defined" do
        expect(shell_aliases["gf"]).to eq("git-flow")
      end
    end
  end
end
