RSpec.describe "Docker", role: "docker" do
  describe app("Docker") do
    it { should exist }
    its(:archs, arm: true) { should include("arm64") }
  end

  describe oh_my_zsh_plugins do
    it { should include("docker", "docker-compose") }
  end

  describe shell_alias("dup") do
    it { should eq("docker compose up") }
  end

  describe shell_alias("bdup") do
    it { should eq("BYEBUG=1 docker compose up") }
  end

  describe shell_alias("dkill") do
    it { should eq("docker compose kill") }
  end

  describe program("hadolint") do
    its(:location) { should eq nix_profile_bin }
    its("--version") { should be_success }

    it "runs without errors" do
      result = command("hadolint -f json -", input: "MAINTAINER deprecated")

      aggregate_failures do
        expect(result.stdout.as_json).to include(a_hash_including code: "DL4000")
        expect(result.stderr).to be_empty
      end
    end
  end
end
