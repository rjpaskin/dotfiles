RSpec.describe "Git", role: "git" do
  describe neovim_packages do
    it { should include("vim-fugitive", "vim-rhubarb") }
  end

  describe oh_my_zsh_plugins do
    it { should include("git") }
  end

  describe xdg_config_path("git/attributes") do
    it { should be_a_file.and be_readable }

    context 'merge drivers' do
      using_tmpdir do |tmp|
        command!("git init '#{tmp}'")
      end

      let(:files) do
        %w[db/schema.rb db/schema_next.rb].map {|name| "'#{name}'" }.join(" ")
      end

      let(:attr) { "merge" }

      let(:git_attributes) do
        check = command!("git -C '#{tmpdir}' check-attr -z #{attr} #{files}")

        # format: <file>\0<attr>\0<value>\0 (repeated)
        check.line.split("\0").each_slice(3).with_object({}) do |(file, _, value), attrs|
          attrs[file] = value
        end
      end

      it "sets up merge driver for `schema.rb` and similar" do
        expect(git_attributes).to all have_attributes(last: "railsschema")
      end
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

  describe "SourceTree" do
    describe home_path("Library/Application Support/SourceTree/sourcetree.license") do
      it { should be_a_file.and be_readable }
      it { should_not be_in_nix_store }
      its(:realpath) { should be_inside(icloud_path "dotfiles") }
    end

    describe app("Sourcetree") do
      it { should exist }
    end

    describe program("stree") do
      its("--version") { should be_success }
    end

    # Test a few with the assumption that others are set correctly as well
    describe defaults("com.torusknot.SourceTreeNotMAS") do
      its("agreedToUpdateConfig") { should eq(false) }
      its("diffFontName") { should eq("Monaco") }
      its("diffFontSize") { should eq(12.0) }
    end
  end

  describe program("git-when-merged") do
    its(:location) { should eq profile_bin }
  end

  context "git-flow", role: "git-flow" do
    describe program("git-flow") do
      its(:location) { should eq profile_bin }
    end

    describe oh_my_zsh_plugins do
      it { should include("git-flow") }
    end

    describe shell_alias("gf") do
      it { should eq("git-flow") }
    end
  end

  context "git-standup", role: "git-standup" do
    describe program("git-standup") do
      its(:location) { should eq profile_bin }
    end
  end
end
