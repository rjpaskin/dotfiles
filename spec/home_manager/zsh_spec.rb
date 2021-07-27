RSpec.describe "ZSH" do
  describe profile_bin("zsh") do
    it { should be_an_executable }
  end

  describe program("zsh") do
    its(:location) { should eq profile_bin }
    its(:manpage) { should be_inside profile_path("share/man") }

    it "runs ok" do
      expect(run_in_shell("exit").stderr.gsub(" > ", "")).to be_empty
    end
  end

  describe oh_my_zsh_plugins do
    it { should include("osx", "history-substring-search") }
  end

  context "setup" do
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
    end

    it "loads Nix profile script" do
      aggregate_failures do
        expect(login_env).to include("NIX_PATH", "NIX_PROFILES")
        expect(login_env["NIX_SSL_CERT_FILE"].as_path).to be_a_file
      end
    end

    describe nix_path_entry(home_path ".nix-defexpr/channels") do
      it { should_not be_present }
    end

    describe nix_path_entry(:nixpkgs) do
      it { should be_present }
      its(:path) { should be_in_nix_store }
    end

    describe nix_path_entry(:"home-manager") do
      it { should be_present }
      its(:path) { should be_in_nix_store }
    end

    describe path_entry(profile_path "bin") do
      it { should be_present }
      it { should be_before shell_variable("PATH")["/usr/local/bin"] }

      context "on ARM", :arm do
        it { should be_before shell_variable("PATH")[homebrew_path "bin"] }
        it { should be_before shell_variable("PATH")[homebrew_path "sbin"] }
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

      expect(hashes).to include("iCloud", "dotfiles", "nixpkgs", "home-manager")

      aggregate_failures do
        expect(hashes["iCloud"]).to eq(icloud_path)
        expect(hashes["dotfiles"]).to eq(dotfiles_path)
        expect(hashes["nixpkgs"]).to be_a_directory.and be_in_nix_store
        expect(hashes["home-manager"]).to be_a_directory.and be_in_nix_store
      end
    end
  end
end
