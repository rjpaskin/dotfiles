RSpec.describe "Bootstrap" do
  describe "full-disk encryption" do
    it "is enabled" do
      expect(command!("fdesetup status").stdout.chomp).to eq("FileVault is On.")
    end
  end

  context "Nix" do
    describe program("nix") do
      its("--version") { should be_success.and(include "Determinate Nix") }
    end

    describe directory("/nix/store") do
      it { should be_a_directory.and be_readable }
    end

    describe program("nix-daemon") do
      it { should be_running }
    end

    describe program("determinate-nixd") do
      its(%i[version]) { should be_success }
    end

    describe directory("/nix/var/nix/profiles/per-user") do
      it { should be_a_directory.and be_readable }
    end

    describe xdg_state_path("nix/profiles") do
      it { should be_a_directory.and be_readable }
    end

    describe file("/etc/nix/nix.custom.conf") do
      it { should be_a_symlink.and be_in_nix_store }
      it { should be_a_file.and be_readable }

      let(:expected_config) do
        { "keep-outputs" => true }
      end

      it "has settings that override defaults" do
        aggregate_failures do
          expected_config.each do |key, value|
            expect(subject.lines).to include("#{key} = #{value}")
            expect(command!("nix config show #{key}").line).to eq(value.to_s)
          end
        end
      end
    end

    describe file("/etc/nix-darwin/flake.nix") do
      it { should be_a_symlink }
      its(:realpath) { should eq(dotfiles_path "flake.nix") }
    end

    context "home-manager" do
      describe xdg_state_path("home-manager/gcroots/current-home") do
        it { should be_a_directory.and be_in_nix_store }

        it "links to a valid generation" do
          expect(subject.children.map(&:basename_str)).to include(
            "home-path", "home-files", "activate"
          )
        end
      end
    end

    describe file("/etc/nix/registry.json") do
      it "pins nixpkgs to locked input for dotfiles" do
        flake_url = command!("nix flake metadata --json '#{dotfiles_path}'").as_json.fetch(:url)

        nixpkgs_path = command!("nix eval --json --file -", input: <<~NIX).as_json
          (builtins.getFlake "#{flake_url}").inputs.nixpkgs.outPath
        NIX

        # Sanity check
        expect(file(nixpkgs_path)).to exist.and be_in_nix_store

        expect(subject.as_json.fetch(:flakes)).to include(
          from: { type: "indirect", id: "nixpkgs" },
          to: { type: "path", path: nixpkgs_path }
        )
      end
    end

    context "legacy" do
      describe shell_command!("nix-channel --list") do
        its(:stdout) { should be_empty }
      end

      describe home_path(".nix-profile") do
        it { should_not exist }
        it { should_not be_a_symlink }
      end

      describe home_path(".nix-defexpr") do
        it { should_not exist }
        it { should_not be_a_symlink }
      end
    end

    describe "NIX_PATH" do
      it "redirects to flake registry" do
        expect(command!("nix config show nix-path").line).to eq("nixpkgs=flake:nixpkgs")
      end
    end
  end

  describe shell_variable("TERMINFO_DIRS") do
    let(:ghostty_terminfo) { directory("/Applications/Ghostty.app/Contents/Resources/terminfo") }

    before do
      expect(ghostty_terminfo).to exist.and(be_a_directory)
    end

    its(:search_path) { should include(ghostty_terminfo) }
  end

  describe file("/etc/pam.d/sudo_local") do
    let(:parsed_content) { subject.lines.map {|line| line.split(/\s+/) } }

    it 'has TouchID and reattach plugins' do
      expect(parsed_content).to include(
        # TouchID
        ["auth", "sufficient", "pam_tid.so"],
        # reattach
        [
          "auth",
          "optional",
          a_string_ending_with("/pam_reattach.so")
          .and(start_with "/nix/store")
          .and(satisfy {|path| File.file?(path) && ShellLib::Path.new(path).mach_binary? })
        ]
      )
    end
  end

  context "Firewall" do
    it "is enabled" do
      if ShellLib.macos_version >= :sequoia
        expect(
          command!("/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate")
        ).to be_success.and include("enabled")
      else
        expect(
          defaults("/Library/Preferences/com.apple.alf")["globalstate"]
        ).to eq(1)
      end
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
end
