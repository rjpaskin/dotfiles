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

    describe "others" do
      let(:values) do
        {
          "arrangement" => [nil, *%i[name dateadded datemodified datecreated kind]],
          "showas" => %i[auto fan grid list],
          "displayas" => %i[stack folder]
        }
      end

      let(:directory_type) { 2 }

      def dock_item(path, **others)
        an_object_having_attributes(
          file_type: directory_type,
          show_as: :grid,
          display_as: :folder,
          path: path,
          label: path.basename_str,
          **others
        )
      end

      def to_value(config, name)
        possibles = values.fetch(name)
        actual = config[name]
        return "<invalid> (#{actual.inspect})" unless actual.is_a?(Integer)

        possibles[config[name]] || "<unknown> (#{actual})"
      end

      subject do
        super()["persistent-others"].map do |config|
          tile_data = config.fetch("tile-data", {})

          OpenStruct.new(
            path: ShellLib::Path.from_uri(tile_data.dig("file-data", "_CFURLString")),
            label: tile_data["file-label"],
            file_type: tile_data["file-type"],
            arrangement: to_value(tile_data, "arrangement"),
            show_as: to_value(tile_data, "showas"),
            display_as: to_value(tile_data, "displayas")
          )
        end
      end

      let(:expected) do
        [
          dock_item(directory("/Applications"), arrangement: :name),
          dock_item(home_path("Documents"), arrangement: :kind),
          dock_item(home_path("Downloads"), arrangement: :dateadded)
        ]
      end

      it { should match(expected) }
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
