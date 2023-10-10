RSpec.describe "Bootstrap" do
  describe "full-disk encryption" do
    it "is enabled" do
      expect(command!("fdesetup status").stdout.chomp).to eq("FileVault is On.")
    end
  end

  context "Nix" do
    describe directory("/nix/store") do
      it { should be_a_directory.and be_readable }
    end

    describe program("nix-daemon") do
      it { should be_running }
    end

    describe nix_profiles_path do
      it { should be_a_directory.and be_readable }
    end

    describe nix_profiles_path(xdg: true) do
      it { should be_a_directory.and be_readable }
    end

    describe nix_profiles_path("profile") do
      it { should be_a_directory.and be_in_nix_store }
    end

    describe home_path(".nix-profile") do
      it { should be_a_directory.and be_in_nix_store }
    end

    describe shell_command!("nix-channel --list") do
      its(:stdout) { should be_empty }
    end

    describe xdg_config_path("nix/nix.conf") do
      it { should be_a_symlink }
      it { should be_a_file.and be_readable }
    end

    context "home-manager" do
      describe nix_profiles_path("home-manager", xdg: true) do
        it { should be_a_directory.and be_in_nix_store }

        it "links to a valid generation" do
          expect(subject.children.map(&:basename_str)).to include(
            "home-path", "home-files", "activate"
          )
        end
      end
    end
  end

  context "Finder" do
    describe home_path("Library") do
      it { should_not be_hidden }
    end

    describe directory("/Library") do
      it { should_not be_hidden }
    end
  end

  context "Firewall" do
    it "is enabled" do
      expect(
        defaults("/Library/Preferences/com.apple.alf")["globalstate"]
      ).to eq(1)
    end

    it "is running" do
      expect(program "socketfilterfw").to be_running
    end
  end

  context "Rosetta 2", :arm do
    it "is installed" do
      expect(program "oahd").to be_running
    end
  end

  context "Homebrew" do
    describe program("brew") do
      its("--version") { should include(/homebrew/i) }
    end
  end

  context "SSH" do
    it "has a key present" do
      expect(
        home_path(".ssh").children.map(&:basename_str)
      ).to include(/^id_(rsa|ed25519)$/)
    end

    it "has a key loaded in the SSH agent" do
      expect(
        command!("/usr/bin/ssh-add -L").lines
      ).to include(/^ssh-(rsa|ed25519)\s/)
    end
  end
end
