RSpec.describe "React Native", role: "react-native" do
  android_home = home_path("Library/Android/sdk")

  describe shell_variable("ANDROID_HOME") do
    it { should eq(android_home) }
  end

  let(:other_path) { shell_variable("PATH")["/bin"] }

  describe path_entry(android_home.join "emulator") do
    it { should be_present }
    it { should be_after(other_path) }
  end

  describe path_entry(android_home.join "tools") do
    it { should be_present }
    it { should be_after(other_path) }
  end

  describe path_entry(android_home.join "tools/bin") do
    it { should be_present }
    it { should be_after(other_path) }
  end

  describe path_entry(android_home.join "platform-tools") do
    it { should be_present }
    it { should be_after(other_path) }
  end
end
