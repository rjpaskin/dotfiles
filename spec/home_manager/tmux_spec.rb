RSpec.describe "Tmux" do
  context "when enabled", role: "tmux" do
    describe program("tmux") do
      its(:location) { should eq profile_bin }
      its(:manpage) { should be_inside profile_path("share/man") }

      it "runs without errors" do
        result = run_in_shell("tmux list-commands")

        aggregate_failures do
          expect(result).to be_success
          expect(result.stdout.lines.size).to be > 1
          expect(result.stderr).to be_empty
        end
      end
    end

    describe program("reattach-to-user-namespace") do
      its(:location) { should eq profile_bin }

      it "runs without errors" do
        result = command("reattach-to-user-namespace -l zsh -c 'echo hello'")

        aggregate_failures do
          expect(result).to be_success
          expect(result.stdout.chomp).to eq("hello")
          expect(result.stderr).to be_empty
        end
      end
    end

    describe home_path(".tmux.conf") do
      it { should be_a_file.and be_readable }
      it { should_not be_blank }
    end
  end

  context "tmate", role: "tmate" do
    describe program("tmate") do
      its(:location) { should eq profile_bin }
    end
  end
end
