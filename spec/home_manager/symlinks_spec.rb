RSpec.describe "Symlinks" do
  describe home_path("Library/Preferences/com.github.atom.plist") do
    it { should be_a_symlink }
    it { should be_writable }

    it "does not point to a file in the Nix store" do
      expect(subject.realpath).not_to start_with("/nix/store")
    end
  end
end
