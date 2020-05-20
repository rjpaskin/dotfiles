RSpec.describe "React Native", role: "react-native" do
  describe shell_variable("ANDROID_HOME") do
    it { should eq(home_path "Library/Android/sdk") }
  end

  describe shell_variable("PATH") do
    let(:android_home) { shell_variable("ANDROID_HOME").as_path }
    let(:paths) do
      %w[emulator tools tools/bin platform-tools].map {|path| android_home.join(path) }
    end

    it { should include(*paths) }

    it "has android tools at the end" do
      base_path_position = subject.index("/bin")
      expect(base_path_position).to be_a(Integer)

      aggregate_failures do
        paths.each do |path|
          expect(subject.index(path)).to be > base_path_position
        end
      end
    end
  end
end
