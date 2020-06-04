RSpec.describe "Docker", role: "docker" do
  describe oh_my_zsh_plugins do
    it { should include("docker", "docker-compose") }
  end

  describe shell_alias("dup") do
    it { should eq("docker-compose up") }
  end

  describe shell_alias("bdup") do
    it { should eq("BYEBUG=1 docker-compose up") }
  end

  describe shell_alias("dkill") do
    it { should eq("docker-compose kill") }
  end
end
