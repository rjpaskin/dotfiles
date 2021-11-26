require "uri"

RSpec.describe "macOS defaults" do
  describe defaults("com.apple.dock") do
    describe "apps" do
      subject do
        super()["persistent-apps"].map do |app|
          ShellLib::Path.from_uri(
            app.dig("tile-data", "file-data", "_CFURLString")
          )
        end
      end

      it { should include app("Launchpad") }
      it { should include app("Google Chrome") }
      it { should include app("Utilities/Activity Monitor") }
      it { should include app("iTerm") }
      it { should include app("System Preferences") }

      context "with git role", role: "git" do
        it { should include app("Sourcetree") }
      end
    end
  end
end
