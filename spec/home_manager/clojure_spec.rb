RSpec.describe "Clojure", role: "clojure" do
  describe program("clojure") do
    its(:location) { should eq profile_bin }
    its(:manpage) { should be_inside profile_path("share/man") }
  end

  describe program("clj") do
    its(:location) { should eq profile_bin }
  end

  describe program("lein") do
    its(:location) { should eq profile_bin }
  end

  describe neovim_packages do
    it { should include("conjure", "vim-sexp",
                        "vim-sexp-mappings-for-regular-people") }
  end

  describe oh_my_zsh_plugins do
    it { should include("lein") }
  end

  describe home_path(".lein/profiles.clj") do
    it { should be_a_file.and be_readable }
  end
end
