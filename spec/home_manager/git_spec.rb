RSpec.describe "Git", role: "git" do
  describe neovim_packages do
    it { should include("vim-fugitive", "vim-rhubarb") }
  end

  describe oh_my_zsh_plugins do
    it { should include("git") }
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

  context "git-flow", role: "git-flow" do
    describe oh_my_zsh_plugins do
      it { should include("git-flow") }
    end

    describe shell_alias("gf") do
      it { should eq("git-flow") }
    end
  end
end
