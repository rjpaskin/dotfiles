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

    nix_profile = directory("/nix/var/nix/profiles/per-user/#{ENV["USER"]}")

    describe nix_profile do
      it { should be_a_directory.and be_readable }
    end

    describe nix_profile.join("profile") do
      it { should be_a_directory.and be_in_nix_store }
    end

    describe home_path(".nix-profile") do
      it { should be_a_directory.and be_in_nix_store }
    end

    describe home_path(".nix-defexpr") do
      it { should be_a_directory.and be_readable }
    end

    describe nix_channel("nixpkgs") do
      its(:url) { should eq("https://nixos.org/channels/nixpkgs-unstable") }
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
      describe nix_channel("home-manager") do
        its(:url) { should eq("https://github.com/rycee/home-manager/archive/master.tar.gz") }
      end

      describe xdg_config_path("nixpkgs/home.nix") do
        it { should be_a_symlink }
        it { should be_a_file.and be_readable }
      end

      describe nix_profile.join("home-manager") do
        it { should be_a_directory.and be_in_nix_store }

        it "links to a valid generation" do
          expect(subject.children.map(&:basename)).to include(
            file("home-path"), file("home-files"), file("activate")
          )
        end
      end

      describe profile_bin("home-manager") do
        it { should be_an_executable }
      end

      describe program("home-manager") do
        its(:location) { should eq profile_bin }
      end

      it "works ok" do
        result = run_in_shell!("home-manager generations")

        aggregate_failures do
          expect(result).to be_success
          expect(result.stdout.lines.size).to be >= 1
        end
      end
    end
  end
end
