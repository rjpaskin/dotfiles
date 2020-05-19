RSpec.describe "React Native", role: "react-native" do
  it "adds $ANDROID_HOME" do
    expect(shell_variable "ANDROID_HOME").to eq(home_path "Library/Android/sdk")
  end

  it "adds android tools to end of $PATH" do
    android_home = shell_variable("ANDROID_HOME")
    shell_path = shell_variable("PATH")
    paths = %W[
      #{android_home}/emulator
      #{android_home}/tools
      #{android_home}/tools/bin
      #{android_home}/platform-tools
    ]

    base_path_position = shell_path.index("/bin")
    expect(base_path_position).to be_a(Integer)

    aggregate_failures do
      expect(shell_path).to include(*paths)

      paths.each do |path|
        expect(shell_path.index(path)).to be > base_path_position
      end
    end
  end
end
