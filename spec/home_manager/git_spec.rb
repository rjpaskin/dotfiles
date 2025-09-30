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

  # Created by SourceTree unless we stop it from managing Git config files
  describe home_path(".gitconfig") do
    it { should be_absent }
  end

  # Created by SourceTree unless we stop it from managing Git config files
  describe home_path(".gitignore_global") do
    it { should be_absent }
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

  describe "GitHub CLI" do
    describe program("gh") do
      its("--version") { should be_success }
    end

    describe zsh_completion("gh") do
      it { should eq("_gh") }
    end

    describe xdg_config_path("gh/config.yml") do
      its(:yaml_content) { should include("git_protocol" => "ssh", "editor" => "nvim") }
    end
  end

  describe "SourceTree" do
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

  describe program("merge-rails-schema") do
    context 'derivation' do
      using_tmpdir do |tmp|
        tmp.join("bin/git-test-script").write(<<~SHELL).mk_executable
          #!/usr/bin/env sh
          set -euo pipefail

          which merge-rails-schema
        SHELL
      end

      let(:script_path) do
        shell_command!(%[env PATH="#{tmpdir}/bin:$PATH" git test-script]).as_path
      end

      it "has patched shebang" do
        expect(script_path.shebang.interpreter).to have_attributes(
          name: "ruby",
          in_nix_store?: true
        )
      end

      it "uses same ruby as Nix profile" do
        profile_ruby = ShellLib::Program.new(nix_profile_bin("ruby"))

        expect(script_path.shebang.interpreter.cmds["--version"].line)
          .to eq(profile_ruby.cmds["--version"].line)
      end
    end

    context 'functionality' do
      def schema_content(timestamp:)
        <<~RUBY
          # This file is auto-generated from the current state of the database. Instead
          # of editing this file, please use the migrations feature of Active Record to
          # incrementally modify your database, and then regenerate this schema definition.
          #
          # Note that this schema.rb definition is the authoritative source for your
          # database schema. If you need to create the application database on another
          # system, you should be using db:schema:load, not running all the migrations
          # from scratch. The latter is a flawed and unsustainable approach (the more migrations
          # you'll amass, the slower it'll run and the greater likelihood for issues).
          #
          # It's strongly recommended that you check this file into your version control system.

          ActiveRecord::Schema.define(version: #{timestamp}) do

            create_table "some_table" do
            end
          end
        RUBY
      end

      def git(*args)
        command("git -C '#{tmpdir}' #{args.join(" ")}")
      end

      def git!(*args)
        git(*args).check!
      end

      def create_merge_conflict(digit_separator:)
        timestamp_base = %w[2023 01 02].join(digit_separator) + digit_separator

        schema_file.write schema_content(timestamp: "#{timestamp_base}091011")
        git!("add .")
        git!("commit -m 'init'")

        main_branch = git("symbolic-ref --short HEAD").stdout

        git!("checkout -b other")
        schema_file.write schema_content(timestamp: "#{timestamp_base}091012")
        git!("commit -a -m 'init'")

        git!("checkout #{main_branch}")
        schema_file.write schema_content(timestamp: "#{timestamp_base}091019")
        git!("commit -a -m 'change'")
      end

      using_tmpdir do |tmp|
        command!("git init '#{tmp}'")
      end

      let(:schema_file) { tmpdir.join("db/schema.rb") }

      it "automatically resolves conflicts for schema files" do
        create_merge_conflict(digit_separator: "")

        expect(git "merge other").to be_success
      end

      it "handles underscored timestamps in schema files" do
        create_merge_conflict(digit_separator: "_")

        expect(git "merge other").to be_success
      end
    end
  end

  describe program("git-when-merged") do
    its(:location) { should eq nix_profile_bin }
  end

  context "git-flow", role: "git-flow" do
    describe program("git-flow") do
      its(:location) { should eq nix_profile_bin }
    end

    describe oh_my_zsh_plugins do
      it { should include("git-flow") }
    end

    describe shell_alias("gf") do
      it { should eq("git-flow") }
    end
  end

  context "git-standup" do
    describe program("git-standup") do
      its(:location) { should eq nix_profile_bin }
    end
  end
end
