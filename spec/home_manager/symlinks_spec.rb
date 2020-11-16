RSpec.describe "Symlinks" do
  describe home_path("Library/Preferences/com.github.atom.plist") do
    it { should be_a_symlink.and be_writable }
  end

  [
    ".atom/config.cson",
    ".atom/init.coffee",
    ".atom/keymap.cson",
    ".atom/snippets.cson",
    ".atom/styles.less",
    ".emacs.d",
    "Library/Application Support/Dash/library.dash",
    "Library/Preferences/com.agilebits.onepassword4.plist",
    "Library/Preferences/com.apple.Terminal.plist",
    "Library/Preferences/com.apple.symbolichotkeys.plist",
    "Library/Preferences/com.bitgapp.eqMac2.plist",
    "Library/Preferences/com.github.atom.plist",
    "Library/Preferences/com.googlecode.iterm2.plist",
    "Library/Preferences/com.kapeli.dash.plist",
    "Library/Preferences/com.kapeli.dashdoc.plist",
    "Library/Preferences/info.marcel-dierkes.KeepingYouAwake.plist"
  ].each do |symlink_path|
    describe home_path(symlink_path) do
      it { should be_a_symlink.and be_writable }
      it { should_not be_in_nix_store }
    end
  end
end
