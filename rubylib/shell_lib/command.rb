require "open3"

module ShellLib
  class Command
    class ExecutionError < StandardError
      attr_reader :command

      def initialize(command)
        @command = command

        message = "<err> #{command.stderr}" unless command.stderr.empty?
        message = "<out> #{command.stdout}" unless command.stdout.empty?
        message ||= "<Unknown error>"

        super("`#{command}`\n#{message}")
      end
    end

    Status = Struct.new(:raw) do
      def ==(other)
        other.is_a?(Integer) ? raw.exitstatus == other : super
      end

      def to_i
        raw.exitstatus
      end

      def success?
        raw.success?
      end

      def failed?
        !success?
      end
    end

    def initialize(*args)
      @command = args.flatten
    end

    %i[stdout stderr status].each do |method|
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def #{method}
          run
          @#{method}
        end
      RUBY
    end

    %i[success? failed?].each do |method|
      class_eval <<~RUBY
        def #{method}; status.#{method}; end
      RUBY
    end

    alias_method :error?, :failed?

    def check!
      raise ExecutionError, self if failed?

      self
    end

    def method_missing(name, *args, &block)
      return super unless stdout.respond_to?(name)

      stdout.send(name, *args, &block)
    end

    def respond_to_missing?(name, include_all = false)
      stdout.respond_to?(name, include_all)
    end

    def to_s
      command.join(" ")
    end

    private

    attr_reader :command

    def spawn_args
      command
    end

    def run
      return if run?

      stdout, stderr, status = execute

      @stdout = Output.new(stdout)
      @stderr = Output.new(stderr)
      @status = Status.new(status)
    end

    def run?
      defined?(@status) && @status.is_a?(Status)
    end

    def execute
      args = spawn_args.dup
      options = args.last
      options[:stdin_data] = options.delete(:input) if Hash === options && options.key?(:input)

      Open3.capture3(*spawn_args)
    end
  end
end
