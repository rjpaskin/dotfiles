module GitCI
  class CLI
    attr_reader :args

    def initialize(args)
      @args = args.dup
    end

    def ci
      if File.directory? ".circleci"
        repo = git("remote get-url origin").split(/:/).last.gsub(/\.git/, %{})

        CircleCI.new(repo)
      else
        quit "Unable to determine CI service"
      end
    end

    def table(rows)
      columns = rows.transpose

      columns.map! do |column|
        max_length = column.max_by(&:length).length
        column.map {|cell| cell.ljust(max_length) }
      end

      puts columns.transpose.map {|row| row.join("    ") }
    end

    def quit(message)
      warn message
      exit 1
    end

    def git(command)
      `git #{command}`.chomp
    end

    def run
      args.unshift("open") if args.none?
      command = args.first

      # common setup
      branch = ARGV[1] || git("symbolic-ref --short HEAD")

      case command
      when "open", "browse"
        system "open #{ci.html_url branch: branch}"
      when "status"
        if %w[--all -a].include? branch
          table ci.all_builds
        else
          table ci.branch_builds(branch: branch)
        end
      when "failing-test-files"
        if branch =~ /^--build.(\d+)$/
          puts ci.failing_test_files(build_num: Regexp.last_match[1])
        else
          puts ci.failing_test_files(branch: branch)
        end
      when "failing-tests"
        if branch =~ /^--build.(\d+)$/
          puts ci.failing_tests(build_num: Regexp.last_match[1]).to_a
        else
          puts ci.failing_tests(branch: branch).to_a
        end
      else
        quit "Unknown command: #{command}"
      end
    end
  end
end
