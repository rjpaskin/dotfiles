RSpec.describe "Symlinks" do
  describe home_path("Library/Preferences/com.github.atom.plist") do
    it { should be_a_symlink }
    it { should be_writable }
    it { should_not be_in_nix_store }
  end
end
