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

    describe nix_profiles_path do
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

    context "config" do
      describe xdg_config_path("nix/nix.conf") do
        it { should be_a_symlink }
        it { should be_a_file.and be_readable }
      end

      describe xdg_config_path("nixpkgs/overlays.nix") do
        it { should be_a_symlink }
        it { should be_a_file.and be_readable }
      end
    end

    context "home-manager" do
      describe nix_profiles_path("home-manager") do
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
        command!("defaults read /Library/Preferences/com.apple.alf globalstate").chomp
      ).to eq("1")
    end

    it "is running" do
      expect(command "/usr/bin/pgrep -q socketfilterfw").to be_success
    end
  end

  context "Rosetta 2", :arm do
    it "is installed" do
      expect(
        file("/Library/Apple/System/Library/LaunchDaemons/com.apple.oahd.plist")
      ).to be_a_file
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
