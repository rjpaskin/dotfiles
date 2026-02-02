RSpec.describe "SSH" do
  describe home_path(".ssh/config") do
    it { should be_a_file.and be_readable }
    it { should include(/^\s+UseKeychain\s+yes/) }

    it "specifies a key to use" do
      key_file = file(subject.content[%r{\s+IdentityFile\s+(~/\.ssh/id_\S+)}, 1])
      raise "No key file found" unless key_file

      expect(key_file).to exist
    end
  end

  describe file("/etc/ssh/ssh_config.d/100-nix-darwin.conf") do
    it { should include(%r{\s+IdentityFile\s+~/\.ssh/%h/id_}) }
  end

  it "has a key present on disk" do
    expect(
      home_path(".ssh").children.map(&:basename_str)
    ).to include(/^id_(rsa|ed25519)$/)
  end

  let(:user_rw_only) { ShellLib::Path.mode(0600) }

  it "has all keys with correct file permissions" do
    private_keys = home_path(".ssh")
      .glob("**/id_*")
      .reject {|path| path.extname == ".pub" }

    expect(private_keys).to all have_attributes(mode: user_rw_only)
  end

  it "has a key loaded in the SSH agent" do
    expect(
      command!("/usr/bin/ssh-add -L").lines
    ).to include(/^ssh-(rsa|ed25519)\s/)
  end
end
