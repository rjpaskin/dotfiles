RSpec.describe "SSH" do
  describe home_path(".ssh/config") do
    it { should be_a_file.and be_readable }
    it { should include(/^\s+UseKeychain\s+yes/) }

    it "specifies file added by bootstrap" do
      key_file = file(subject.content[/\s+IdentityFile (.+)/, 1])
      raise "No key file found" unless key_file

      expect(key_file).to exist
    end
  end

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
