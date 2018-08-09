require "erb"
require "uri"
require "net/http"
require "json"
require "ostruct"
require "set"
require "time"
require "yaml"

module GitCI
  class CircleCI
    autoload :Build, "git-ci/circle_ci/build"
    autoload :RSpecOutput, "git-ci/circle_ci/rspec_output"
    autoload :TestResult, "git-ci/circle_ci/test_result"

    HTML_URL_TEMPLATE = "https://circleci.com/gh/%{repo}/tree/%{branch}".freeze
    PARAM = /%\{([a-z_]+)\}/

    def initialize(repo)
      @repo = repo
    end

    def html_url(branch:)
      interpolate(HTML_URL_TEMPLATE, branch: branch)
    end

    def branch_builds(branch:, limit: 5, **params)
      get("project/github/%{repo}/tree/%{branch}", branch: branch, limit: limit, **params) do |response|
        response.map {|data| Build.new(data, detail: :commit_message) }
      end
    end

    def all_builds
      get("project/github/%{repo}", limit: 15) do |response|
        response.map {|data| Build.new(data, detail: :branch) }
      end
    end

    def failing_test_files(branch: nil, build_num: nil)
      with_build(url: "project/github/%{repo}/%{build_num}/tests", branch: branch, build_num: build_num, default: []) do |response|
        response[:tests].map {|data| TestResult.new(data) }
      end.select(&:failed?).map(&:file).uniq.sort
    end

    def failing_tests(branch: nil, build_num: nil)
      with_build(url: "project/github/%{repo}/%{build_num}", branch: branch, build_num: build_num, default: []) do |response|
        response.fetch(:steps).each_with_object(SortedSet.new) do |step, results|
          step.fetch(:actions, []).each do |action|
            next unless action[:bash_command] =~ /rspec/
            next unless action[:status] == "failed"
            next unless action[:has_output]

            get(action[:output_url]) do |response|
              stdout = response.find {|output| output[:type] == "out" } or raise "No stdout output found"

              results.merge RSpecOutput.new(stdout.fetch :message).tests
            end
          end
        end
      end
    end

    private

    attr_reader :repo

    def with_build(url:, branch: nil, build_num: nil, default: nil, &block)
      if branch
        with_last_failing_build(branch: branch, default: default) do |latest_build|
          get(url, build_num: latest_build.num, &block)
        end
      elsif build_num
        get(url, build_num: build_num, &block)
      end
    end

    def with_last_failing_build(branch:, default:, **params)
      latest_build = branch_builds(**params, branch: branch, limit: 1, filter: 'failed').first

      if latest_build
        yield(latest_build)
      else
        default
      end
    end

    def get(path, **params)
      url = path.start_with?("http") ? URI.parse(path) : build_url(path, params)
      response = Net::HTTP.get_response(url)
      response.value # raises error for non-2xx statuses
      yield JSON.parse(response.body, symbolize_names: true)
    end

    def build_url(path, **params)
      URI::HTTPS.build(
        host: "circleci.com",
        path: interpolate("/api/v1.1/#{path}", params),
        query: URI.encode_www_form(params.merge "circle-token" => config["circleci"])
      )
    end

    def interpolate(template, **params)
      params[:repo] = repo
      params[:branch] = ERB::Util.url_encode(params[:branch]) if params[:branch]

      template.gsub(PARAM) do
        key = Regexp.last_match[1]
        params.delete(key.to_sym) || params.delete(key) || raise(KeyError, "#{key.inspect} not provided")
      end
    end

    def config
      @config ||= begin
        config_dir = ENV.fetch("XDG_CONFIG_HOME") { File.join(ENV["HOME"], ".config") }

        YAML.load_file File.join(config_dir, "git-ci", "credentials.yml")
      end
    end
  end
end
