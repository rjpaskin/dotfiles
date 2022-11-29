RSpec.describe "script/bootstrap", :mock_executables do
  subject { dotfiles_path("script/bootstrap") }

  let(:outputs) { tmpdir.join("__outputs").mkpath }

  using_tmpdir do |tmp|
    tmp.join("home/Desktop").mkpath
  end

  let(:patched_script) do
    new_content = subject.read.gsub(%r{.*(?<=\s|")(/[^"\s]+).*}) do
      line, path = Regexp.last_match.to_a

      case line
      when /export PATH=/
        line.sub(path, "#{bin}:#{path}")
      when /oahd\.plist/, /homebrew_prefix/i, %r{/nix/store}
        line.sub(path, "#{tmpdir}#{path}")
      when /(ssh-add|pgrep)/
        line.sub(path, bin.join("usr-bin-#{$1}"))
      else
        line
      end
    end

    new_content.gsub!(/\bsudo\b/, "builtins_sudo")

    tmpdir.join("script/bootstrap").write(new_content).mk_executable
  end

  # Although we patch the script in order to stub executables
  # and prevent the script from making actual changes to the
  # system, this sandbox profile acts as another safeguard
  #
  # Reference: https://reverse.put.as/wp-content/uploads/2011/09/Apple-Sandbox-Guide-v0.1.pdf
  let(:sandbox_profile) do
    permitted_commands = %w[
      arch awk dirname env openssl ssh-keygen sw_vers tee touch uname which
    ]

    tmpdir.join("__sandbox.sb").write(<<~CONTENT)
      (version 1)
      (allow default)
      (import "system.sb")

      (deny network*)
      (allow network*
        (remote unix (subpath "#{dotfiles_path}")))

      (deny file-write*)
      (allow file-write*
        (subpath "#{tmpdir.realpath}")
        (subpath "/private/tmp"))

      (deny process-exec
        (regex #"^(/usr)?/s?bin")
        (subpath "#{dotfiles_path}"))

      (allow process-exec
        (regex #"/usr/bin/(#{permitted_commands.join("|")})")
        (regex #"/bin/(bash|chmod|mkdir|sh)")
        (subpath "#{tmpdir}"))
    CONTENT
  end

  let(:bin) { tmpdir.join("__stubs") }

  let(:nix_installer) do
    <<~SCRIPT
      set -e

      echo "$*" >> #{outputs.join "nix-installer"}
      mkdir -p #{tmpdir.join "nix/store"}
      mkdir -p #{tmpdir.join "home/.nix-profile"}

      # The real Nix installer does this
      export PATH="$HOME/.nix-profile/bin:$PATH"
    SCRIPT
  end

  let(:homebrew_installer) do
    <<~SCRIPT
      set -e

      if [[ "$(uname -v)" == *ARM64* ]]; then
        export prefix="/opt/homebrew"
      else
        export prefix="/usr/local"
      fi

      mkdir -p "#{tmpdir}$prefix/bin"
      touch "#{tmpdir}$prefix/bin/brew"
      chmod +x "#{tmpdir}$prefix/bin/brew"
    SCRIPT
  end

  let(:homebrew_prefix) do
    tmpdir.join(ShellLib.arm? ? "opt/homebrew" : "usr/local")
  end

  let(:icloud_email) { "icloud@example.test" }

  let(:rosetta_2_args) do
    a_collection_containing_exactly("--install-rosetta", "--agree-to-license")
  end

  let(:rosetta_installed?) { false }

  before do
    tmpdir.join("script/switch").write(<<~SCRIPT).mk_executable
      #!/usr/bin/env bash
      set -e

      echo "$PATH" >> #{outputs.join "script-switch"}
      echo "script/switch was run" >&2
    SCRIPT

    stub_command("softwareupdate")
    stub_command("ssh-agent", args: %w[-s]).and_return("echo 'ssh-agent was run' >&2")
    stub_command("ssh-add")
    stub_command("usr-bin-ssh-add")
    stub_command("pgrep")

    stub_command("usr-bin-pgrep") do |input|
      if input.args.last == "oahd"
        if rosetta_installed?
          { status: 0, stdout: "12345" }
        else
          { status: 1 }
        end
      else
        raise "Unknown `pgrep` input: #{input.to_s}"
      end
    end

    stub_command("curl") do |input|
      case input.args.last
      when %r{homebrew/install}i
        homebrew_installer
      when %r{nixos.org.+install}i
        nix_installer
      else
        raise "Unknown `curl` input: #{input.to_s}"
      end
    end

    stub_command("builtins_sudo")

    @hostname = "default.local"

    stub_command("scutil", args: a_collection_including("--set"), sudo: true) do |input|
      @hostname = input.args.last if input.args[1] == "ComputerName"

      input.args.join(" ")
    end

    stub_command("scutil", args: %w[--get ComputerName]) { @hostname }

    stub_command(
      "security",
      args: %w[find-generic-password -s com.apple.account.IdentityServices.token]
    ).and_return(<<~OUTPUT)
        keychain: "#{ENV["HOME"]}/Library/Keychains/login.keychain-db"
        version: 512
        class: "genp"
        attributes:
            0x00000007 <blob>="com.apple.account.IdentityServices.token"
            0x00000008 <blob>=<NULL>
            "acct"<blob>="#{icloud_email}"
            "cdat"<timedate>=0x#{SecureRandom.hex(16)}  "20200101123400Z\\000"
            "crtr"<uint32>=<NULL>
            "cusi"<sint32>=<NULL>
            "desc"<blob>=<NULL>
            "gena"<blob>=0x#{SecureRandom.hex(244)}  "<?xml version="1.0" encoding="UTF-8"?>\\012<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\\012<plist version="1.0">\\012<dict>\\012\\011<key>ACKeychainItemVersion</key>\\012\\011<integer>3</integer>\\012</dict>\\012</plist>\\012"
            "icmt"<blob>=<NULL>
            "invi"<sint32>=<NULL>
            "mdat"<timedate>=0x#{SecureRandom.hex(16)}  "20200101123400Z\\000"
            "nega"<sint32>=<NULL>
            "prot"<blob>=<NULL>
            "scrp"<sint32>=<NULL>
            "svce"<blob>="com.apple.account.IdentityServices.token"
            "type"<uint32>=<NULL>
    OUTPUT
  end

  def run_script(*args)
    calls.clear

    to_run = [
      "env HOME=#{tmpdir}/home",
      "sandbox-exec -f #{sandbox_profile}",
      [patched_script, *args].join(" ")
    ].join(" ")

    command(to_run)
  end

  def run_script!(*args)
    run_script(*args).check!
  end

  def stub_restartables
    # These thing aren't OS- or arch-specific, so stub them
    # as 'complete' so that we don't need to run the script
    # multiple times
    @hostname = "rjp-test"

    stub_command("softwareupdate", args: %w[--list]).and_return(
      generate_softwareupdate_output("No new software available\n")
    )

    stub_command("fdesetup", args: %w[status]).and_return(
      "FileVault is On"
    )
  end

  def fs_snapshot(root = tmpdir)
    {}.tap do |snapshot|
      root.children.each do |file|
        next if %r{/__|/script/bootstrap$}.match?(file)

        filename = file.to_s.sub(tmpdir, "<tmp>")

        unless file.directory?
          snapshot[filename] = File.read(file)
          next
        end

        if file.empty?
          snapshot[filename] = "<empty dir>"
        else
          snapshot.merge!(fs_snapshot file)
        end
      end
    end
  end

  def generate_softwareupdate_output(text)
    stdout = <<~OUTPUT
      Software Update Tool

      Finding available software
    OUTPUT

    { stdout: stdout, stderr: text }
  end

  let(:nix_installer_flags) do
    %w[--no-daemon --no-modify-profile --no-channel-add]
  end

  context "dry run" do
    let(:permitted_invocations) do
      [
        an_invocation_of("scutil", with: %w[--get ComputerName]),
        an_invocation_of("softwareupdate", with: %w[--list]),
        an_invocation_of("fdesetup", with: %w[status]),
        an_invocation_of(
          "security",
          with: %w[find-generic-password -s com.apple.account.IdentityServices.token]
        ),
        an_invocation_of("ssh-agent", with: %w[-s]),
        an_invocation_of("usr-bin-pgrep", with: %w[oahd]),
        *(an_invocation_of("softwareupdate", with: rosetta_2_args) if ShellLib.arm?)
      ]
    end

    context "fresh install (blank slate)" do
      before do
        stub_command("fdesetup", args: %w[status]).and_return(
          "FileVault is Off"
        )
      end

      context "no hostname given" do
        it "still errors with message asking for hostname" do
          result = run_script("--dry-run")

          aggregate_failures do
            expect(result).to be_error
            expect(result.stderr).to include(/provide a hostname/i)
          end
        end
      end

      context "hostname given" do
        it "doesn't make any changes" do
          aggregate_failures do
            expect {
              run_script!("--dry-run test-hostname")
            }.not_to change { fs_snapshot }

            expect(calls).to match_array(permitted_invocations)
          end
        end
      end
    end

    context "hostname already set" do
      before { stub_restartables }

      it "doesn't make any changes" do
        aggregate_failures do
          expect {
            run_script!("--dry-run")
          }.not_to change { fs_snapshot }

          expect(calls).to match_array(permitted_invocations)
        end
      end
    end
  end

  context "fresh install (blank slate)" do
    before do
      stub_command("softwareupdate", args: %w[--list]).and_return(
        generate_softwareupdate_output(<<~OUTPUT),

          macOS mock update 1.2.3.4
            This is a mock update for testing
        OUTPUT
        generate_softwareupdate_output("No new software available.\n")
      )

      stub_command(
        "softwareupdate",
        args: a_collection_containing_exactly("--install", "--all")
      ).and_return("installing updates")

      stub_command("fdesetup", args: %w[status]).and_return(
        "FileVault is Off",
        "FileVault is On"
      )

      stub_command(
        "fdesetup",
        args: ["enable", "-user", ENV["USER"]],
        sudo: true
      ).and_return("filevault_secret")
    end

    context "no argument given" do
      it "errors with message asking for hostname" do
        result = run_script

        aggregate_failures do
          expect(result).to be_error
          expect(result.stderr).to include(/provide a hostname/i)
        end
      end
    end

    context "argument given (on first run)" do
      it "runs successfully" do
        first_run = run_script!("test")

        aggregate_failures do
          expect(first_run.stderr.lines.last(2)).to include(
            /updates installed/i,
            /you should now restart your computer/i
          )
          expect(@hostname).to eq("rjp-test")
          expect(calls).to include(
            a_sudo_invocation_of("scutil", with: %w[--set ComputerName rjp-test]),
            a_sudo_invocation_of("scutil", with: %w[--set HostName rjp-test]),
            a_sudo_invocation_of("scutil", with: %w[--set LocalHostName rjp-test])
          )
          expect(first_run).not_to include(/rosetta/i)
        end

        second_run = run_script!

        aggregate_failures do
          expect(second_run.stderr.lines.last(2)).to include(
            /filevault now enabled/i,
            /you should now restart your computer/i
          )
          expect(
            tmpdir.join("home/Desktop/file_vault_recovery_key.txt")
          ).to include("filevault_secret")

          expect(
            outputs.join("nix-installer").contents.split(" ")
          ).to match_array(
            [*nix_installer_flags, *("--darwin-use-unencrypted-nix-store-volume")]
          )

          expect(second_run.stderr).not_to include(/homebrew/i)
        end

        third_run = run_script!

        aggregate_failures do
          expect(third_run.stderr).to include(/nix already installed/i)
          expect(homebrew_prefix).to be_a_directory
          expect(homebrew_prefix.join("bin/brew")).to be_a_file.and be_an_executable

          expect(third_run.stderr).to include(/generating (a )?new ssh key/i)

          passphrase = tmpdir.join("home/Desktop/ssh_key_passphrase.txt")
          expect(passphrase).to be_a_file.and have_content.and be_only_user_readable
          expect(passphrase.content).to match(/\S{24,}/)

          expect(tmpdir.join "home/.ssh/id_ed25519").to include(
            "BEGIN OPENSSH PRIVATE KEY"
          ).and be_only_user_readable
          expect(tmpdir.join "home/.ssh/id_ed25519.pub").to include(
            "ssh-ed25519",
            icloud_email
          )
          expect(third_run.stderr).to include("ssh-agent was run")
          expect(calls).to include(
            an_invocation_of(
              "usr-bin-ssh-add",
              with: ["-K", tmpdir.join("home/.ssh/id_ed25519")]
            )
          )

          expect(third_run.stderr).to include("script/switch was run")
          path_for_switch_script = ShellLib::SearchPath.parse(
            outputs.join("script-switch").contents
          )
          expect(path_for_switch_script).to_not be_empty
          expect(path_for_switch_script).to have_entry(
            tmpdir.join("home/.nix-profile/bin"), at: 0
          )
        end
      end
    end
  end

  context "on ARM with Big Sur" do
    before do
      stub_os(macos_version: :big_sur, arch: :arm64) unless ShellLib.arm?
      stub_restartables
    end

    let(:homebrew_prefix) { tmpdir.join("opt/homebrew") }

    it "adapts to OS and arch" do
      run_script!

      aggregate_failures do
        expect(calls).to include an_invocation_of(
          "softwareupdate",
          with: rosetta_2_args
        )

        expect(
          outputs.join("nix-installer").contents.split(" ")
        ).to contain_exactly(
          *nix_installer_flags, "--darwin-use-unencrypted-nix-store-volume"
        )

        expect(homebrew_prefix).to be_a_directory
        expect(homebrew_prefix.join("bin/brew")).to be_a_file.and be_an_executable
      end
    end

    context "Rosetta 2 already installed" do
      let(:rosetta_installed?) { true }

      it "doesn't try to install Rosetta 2" do
        run = run_script!

        aggregate_failures do
          expect(calls).not_to include an_invocation_of(
            "softwareupdate",
            with: rosetta_2_args
          )

          expect(run.stderr).to include(/rosetta 2 already installed/i)
        end
      end
    end
  end

  context "SSH key generation" do
    before { stub_restartables }

    def stub_ssh_key(algo)
      { private: "", public: ".pub" }.each do |type, extension|
        ssh_dir.join(
          "id_#{algo.to_s.downcase}#{extension}"
        ).write("dummy #{algo} #{type} key\n").mk_only_user_readable
      end
    end

    let(:ssh_dir) { tmpdir.join("home/.ssh") }

    context "RSA SSH key already exists" do
      before { stub_ssh_key(:rsa) }

      it "skips creation of new SSH key" do
        aggregate_failures do
          expect { run_script! }
            .to not_change(ssh_dir.join("id_rsa"), :contents)
            .and not_change(ssh_dir.join("id_rsa.pub"), :contents)

          expect(ssh_dir.join "id_ed25519").to_not exist
          expect(ssh_dir.join "id_ed25519.pub").to_not exist
        end
      end
    end

    context "Ed25519 SSH key already exists" do
      before { stub_ssh_key(:ed25519) }

      it "skips creation of new SSH key" do
        aggregate_failures do
          expect { run_script! }
            .to not_change(ssh_dir.join("id_ed25519"), :contents)
            .and not_change(ssh_dir.join("id_ed25519.pub"), :contents)

          expect(ssh_dir.join "id_rsa").to_not exist
          expect(ssh_dir.join "id_rsa.pub").to_not exist
        end
      end
    end
  end
end
