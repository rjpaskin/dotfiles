module ShellLib
  class Task
    include ResourceHelpers
    include PathHelpers

    attr_reader :argv

    def self.debug(message)
      warn("[ DEBUG ] #{message}")
    end

    def self.run(argv = ARGV)
      result = new(argv).run
      debug(result) if result.is_a?(String)
    end

    def initialize(argv = ARGV)
      @argv = argv
    end

    def run
      raise NotImplementedError
    end

    def method_missing(name, *args, &block)
      return args if name.to_s.start_with?("args_for_")

      options = (args.last.is_a?(Hash) ? args.pop : {})
      name = name.to_s.sub(/(\?|!)$/, "")
      cmd = send("args_for_#{name}", *("sudo" if options[:sudo]), name, *args).join(" ")

      case name
      when /!$/ then
        simple_command!(cmd)
      when /\?$/
        command(cmd).success?
      else
        command(cmd).check!
      end
    end

    def respond_to_missing?(_name, _include_all = false)
      true
    end

    private

    def debug(message)
      self.class.debug(message)
    end

    def arg?(*args)
      (argv & args).any?
    end
  end
end
