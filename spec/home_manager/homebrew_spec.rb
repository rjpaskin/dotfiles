RSpec.describe "Homebrew" do
  describe program("mas") do
    it "runs under ARM", :arm do
      expect(
        run_in_shell "arch -arm64e /bin/bash -c 'mas version'"
      ).to be_success
    end
  end

  context "casks with separate downloads for ARM" do
    describe program("ngrok"), role: "ngrok" do
      its("--version") { should be_success.and include(/ngrok/i) }
      its(:archs, arm: true) { should include("arm64") }
    end

    describe app("Google Chrome") do
      it { should exist }
      its(:archs, arm: true) { should include("arm64") }
    end

    describe app("Slack"), role: "slack" do
      it { should exist }
      its(:archs, arm: true) { should include("arm64") }
    end

    describe app("VLC") do
      it { should exist }
      its(:archs, arm: true) { should include("arm64") }
    end

    describe app("zoom.us") do
      it { should exist }
      its(:archs, arm: true) { should include("arm64") }
    end
  end

  describe app("MollyGuard") do
    it { should exist }
  end
end
