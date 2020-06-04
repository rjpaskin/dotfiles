RSpec.describe "Go", role: "go" do
  describe oh_my_zsh_plugins do
    it { should include("golang") }
  end

  describe shell_variable("GOPATH") do
    it { should_not be_empty }

    it "is accessible" do
      expect(subject.as_path).to be_a_directory.and be_readable
    end
  end
end
