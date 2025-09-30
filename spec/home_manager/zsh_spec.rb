RSpec.describe "ZSH" do
  describe profile_bin("zsh") do
    it { should be_an_executable }
  end

  describe program("zsh") do
    its(:location) { should eq profile_bin }
    its(:manpage) { should be_inside profile_path("share/man") }
    its(:archs, arm: true) { should include("arm64") }

    it "runs ok" do
      expect(run_in_shell("exit").stderr.gsub(" > ", "")).to be_empty
    end
  end

  describe oh_my_zsh_plugins do
    it { should include("macos", "history-substring-search") }
  end

  context "setup", pending: "TODO" do
    let(:shell_path) { profile_bin("zsh") }

    it "sets user shell to ZSH" do
      user_config = command!(%W[dscl . read #{home} UserShell]).as_vars(
        separator: ": "
      )

      expect(user_config["UserShell"]).to eq(shell_path)
    end

    describe file("/etc/shells") do
      it { should include(/^#{shell_path}$/) }
    end
  end

  describe xdg_config_path("zsh/.zshrc") do
    it { should be_a_file.and be_readable }
    it { should include "/usr/libexec/path_helper -s" }

    context "history" do
      let(:options) { run_in_shell!("setopt").lines }

      describe shell_variable("HISTFILE") do
        it { should eq(xdg_data_path "zsh/history") }
      end

      describe shell_variable("HISTSIZE") do
        it { should eq(50_000) }
      end

      describe shell_variable("SAVEHIST") do
        it { should eq(10_000) }
      end

      it "defines correct history options" do
        expect(options).to include(
          /^hist_?ignore_?dups$/i,
          /^hist_?ignore_?space$/i,
          /^hist_?expire_?dups_?first/i,
          /^share_?history/i,
          /^extended_?history/i
        )
      end
    end

    it "loads Nix completions" do
      expect(shell_functions).to include("_nix-env")
      expect(zsh_completion("nix")).to eq("_nix")
    end

    it "loads Nix profile script" do
      aggregate_failures do
        expect(login_env).to include("NIX_PROFILES")
        expect(login_env["NIX_SSL_CERT_FILE"].as_path).to be_a_file
      end
    end

    describe path_entry(profile_path "bin") do
      it { should be_present }
      it { should be_before path_entry("/usr/local/bin") }

      context "on ARM", :arm do
        it { should be_before path_entry(homebrew_path "bin") }
        it { should be_before path_entry(homebrew_path "sbin") }
      end
    end

    describe manpath_entry(profile_path "share/man") do
      it { should be_present }
      it { should be_before(manpath[homebrew_path "share/man"]) }
      it { should be_before(manpath["/usr/share/man"]) }
    end

    describe shell_variable("ZSH_THEME") do
      it { should eq("robbyrussell") }
    end

    it "defines valid directory hashes" do
      hashes = run_in_shell!("hash -d").as_vars.transform_values(&:as_path)

      a_nix_store_directory = be_a_directory.and be_in_nix_store

      expect(hashes).to include(
        # FIXME
        # "dotfiles" => dotfiles_path,
        "iCloud" => icloud_path,
        "nixpkgs" => a_nix_store_directory,
        "nix-darwin" => a_nix_store_directory,
        "home-manager" => a_nix_store_directory
      )
    end
  end
end
