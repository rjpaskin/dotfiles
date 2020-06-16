RSpec.describe "Heroku", role: "heroku" do
  describe program("heroku") do
    its(:location) { should eq profile_bin }
    its("--version") { should be_success.and include("heroku") }
  end

  describe oh_my_zsh_plugins do
    it { should include("heroku") }
  end

  describe "plugins" do
    let(:data_dir) { xdg_data_path("heroku") }
    let(:plugins) { %w[heroku-accounts heroku-repo] }

    let(:heroku_commands) { run_in_shell!("heroku commands").lines }

    let(:package_json) do
      begin
        data_dir.join("package.json").as_json
      rescue Errno::ENOENT # don't care if package.json is present
        { dependencies: [] }
      end
    end

    let(:yarn_lock) do
      begin
        data_dir.join("yarn.lock").lines
      rescue Errno::ENOENT
        []
      end
    end

    it "does not have plugins installed in $HOME" do
      aggregate_failures do
        plugins.each do |plugin|
          expect(data_dir.join "node_modules", plugin).to be_absent
          expect(package_json[:dependencies]).not_to include(plugin)
          expect(yarn_lock).not_to include(plugin)
        end
      end
    end

    describe "heroku-accounts" do
      it "is installed" do
        expect(heroku_commands).to include("accounts", "accounts:add", "accounts:set")
      end
    end

    describe "heroku-repo" do
      it "is installed" do
        expect(heroku_commands).to include("repo:purge_cache", "repo:gc")
      end
    end
  end

  context "parity", role: "parity" do
    describe program("production") do
      its(:location) { should eq profile_bin }
    end

    describe program("staging") do
      its(:location) { should eq profile_bin }
    end
  end
end
