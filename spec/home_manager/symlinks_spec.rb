RSpec.describe "Symlinks" do
  describe home_path(".emacs.d") do
    it { should be_a_symlink.and be_writable }
    it { should_not be_in_nix_store }
  end
end
