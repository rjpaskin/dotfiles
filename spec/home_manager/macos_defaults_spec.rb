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

      let(:preferences_name) do
        ShellLib.macos_version >= :ventura ? "Settings" : "Preferences"
      end

      it { should include app("Launchpad") }
      it { should include app("Google Chrome") }
      it { should include app("Utilities/Activity Monitor") }
      it { should include app("iTerm") }
      it { should include app("System #{preferences_name}") }

      context "with git role", role: "git" do
        it { should include app("Sourcetree") }
      end
    end
  end

  describe "keyboard mappings" do
    subject do
      defaults(current_host: "NSGlobalDomain").each_pair.with_object([]) do |(key, value), out|
        next unless /^com\.apple\.keyboard\.modifiermapping\.\d+-\d+-0/.match?(key.to_s)

        out << value.map {|mapping| mapping.transform_keys(&:to_sym) }
      end
    end

    let(:base_mask) { 0x700000000 }

    let(:map_caps_lock_to_right_ctrl) do
      {
        HIDKeyboardModifierMappingDst: base_mask | 0xE4,
        HIDKeyboardModifierMappingSrc: base_mask | 0x39
      }
    end

    it { should all include(map_caps_lock_to_right_ctrl) }
  end
end
