RSpec.describe "Packages" do
  let(:nix_profile_manpath) { profile_path("share/man") }

  describe program("ag") do
    its(:location) { should eq profile_bin }
    its(:manpage) { should be_inside nix_profile_manpath }

    let(:needle) { "string for ag to find" }

    it "runs without errors" do
      result = run_in_shell!("ag --vimgrep '#{needle}' '#{File.dirname __FILE__}'")

      expect(result).to include(__FILE__, needle)
    end

    describe xdg_config_path("silver_searcher/ignore") do
      it { should be_a_file.and be_readable }
      it { should include(".git") }
    end

    describe shell_alias("ag") do
      it { should eq("ag --hidden --path-to-ignore ~/.config/silver_searcher/ignore") }
    end
  end

  describe program("chezmoi") do
    its(:location) { should eq profile_bin }
    its("--version") { should be_success }

    describe zsh_completion("chezmoi") do
      it { should eq("_chezmoi") }
    end

    describe xdg_data_path("chezmoi") do
      it { should be_a_symlink }
      its(:realpath) { should eq(dotfiles_path) }
    end

    describe xdg_config_path("chezmoi/chezmoi.toml") do
      # What nix-darwin uses for by default for `darwinConfigurations` key
      let(:hostname) { command!("scutil --get LocalHostName").line }

      it { should be_a_symlink }
      its(:realpath) { should eq(dotfiles_path "hosts/chezmoi/#{hostname}.toml").and exist }
    end
  end

  describe program("ctags") do
    its(:location) { should eq profile_bin }
    its("--version") { should include(/universal ctags/i) }
    its(:manpage) { should be_inside nix_profile_manpath }

    class ClassForCtagsToIndex; end

    it "runs without errors" do
      result = run_in_shell("ctags -f - '#{__FILE__}'")

      aggregate_failures do
        expect(result).to be_success
        expect(result.stdout).to include(__FILE__, "ClassForCtagsToIndex")
        expect(result.stderr).to be_empty
      end
    end

    describe xdg_config_path("ctags/config.ctags") do
      it { should be_a_file.and be_readable }
      it { should include(/--exclude=node_modules/) }
    end

    describe xdg_config_path("ctags/nix.ctags") do
      it { should be_a_file.and be_readable }
      it { should include(/--langdef=Nix/i) }
    end

    it "loads config files without warnings" do
      expect(command! "ctags --list-languages").to be_success.and include("Nix")
    end
  end

  describe program("fzf") do
    its(:location) { should eq profile_bin }
    its(:manpage) { should be_inside nix_profile_manpath }
    its("--version") { should be_success }
  end

  describe program("fzf-tmux") do
    its(:location) { should eq profile_bin }
  end

  # 1Password CLI
  describe program("op") do
    its(:location) { should eq profile_bin }
    its("--version") { should be_success }
  end

  describe program("jq") do
    its(:location) { should eq profile_bin }
    its(:manpage) { should be_inside nix_profile_manpath }
    its("--version") { should be_success }

    it "runs without errors" do
      expect(run_in_shell! "echo '[]' | jq").to be_success
    end
  end

  describe program("shellcheck") do
    its(:location) { should eq profile_bin }
    its(:manpage) { should be_inside nix_profile_manpath }

    it "runs without errors" do
      result = run_in_shell("echo 'ls $1' | shellcheck -s sh -f gcc -")

      aggregate_failures do
        expect(result.status).to eq(1)
        expect(result.stdout).to include("[SC2086]")
      end
    end
  end

  describe program("ncdu") do
    its(:location) { should eq profile_bin }
    its(:manpage) { should be_inside nix_profile_manpath }
    its("--version") { should be_success }

    describe xdg_config_path("ncdu/config") do
      it { should be_a_file.and be_readable }
      it { should include(/--color[= ]off/) }
    end
  end

  describe program("autoterm") do
    its(:location) { should eq profile_bin }
  end

  context 'AWS CLI', role: "aws" do
    describe program("aws") do
      its(:location) { should eq profile_bin }
      its("--version") { should be_success.and start_with("aws-cli/2.") }

      describe xdg_config_path("zsh/.zshrc") do
        let(:zsh_completion_script) do
          %r{source ([^\n]+/share/zsh/site-functions/aws_zsh_completer.sh)}
        end

        it "sources AWS completion script" do
          expect(subject).to include(zsh_completion_script)

          script_path = file(subject.contents[zsh_completion_script, 1].sub("$USER", ENV["USER"]))

          expect(script_path).to exist.and include("compinit")
        end
      end

      describe zsh_completion("aws") do
        it { should eq("_bash_complete -C aws_completer") }
      end
    end

    describe home_path(".aws/config") do
      let(:aws_vault_cmd) do
        %r{^#{profile_bin("aws-vault")} export --format json (?<profile>.+)$}
      end

      let(:profile_heading) do
        /^(?:profile )?(?<name>(?:default|.+))$/
      end

      its(:ini_content) do
        should include(a_string_matching(profile_heading)).and all(
          match(
            [
              a_string_matching(profile_heading),
              "region" => a_string_matching(/^[a-z]{2}-[a-z]+-\d+$/),
              "mfa_serial" => a_string_matching(%r{^arn:aws:iam::\d+:mfa/.+$}),
              "credential_process" => a_string_matching(aws_vault_cmd),
              "mfa_process" => a_string_matching(
                %r{^#{profile_bin("op")} item get \S+ --otp$}
              )
            ]
          )
        )
      end

      it "uses correct profile for credential_process" do
        profiles = subject.ini_content.each_with_object({}) do |(section, config), out|
          profile = section[profile_heading, :name]
          next unless profile

          out[profile] = config
        end

        correct_profiles = profiles.select do |profile, config|
          mfa_profile = config["credential_process"].to_s[aws_vault_cmd, :profile]

          profile == mfa_profile
        end

        expect(profiles).not_to be_empty
        expect(correct_profiles).to eq(profiles)
      end

      it "is managed by chezmoi" do
        managed_files = command!("chezmoi managed").lines

        expect(managed_files).to include(".aws/config")
      end
    end

    describe program("session-manager-plugin") do
      its(:location) { should eq profile_bin }

      it "runs OK" do
        result = command("session-manager-plugin")

        aggregate_failures do
          expect(result.status).to eq(0)
          expect(result.stdout).to include(/installed successfully/i)
        end
      end
    end

    describe program("aws-vault") do
      its(:location) { should eq profile_bin }
      its("--version") { should be_success }

      describe shell_variable("AWS_VAULT_KEYCHAIN_NAME") do
        it { should eq("login") }
      end
    end
  end
end
