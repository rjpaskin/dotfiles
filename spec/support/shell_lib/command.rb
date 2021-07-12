module ShellLib
  class Command
    class ExecutionError < StandardError; end

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

    MODE = begin
      raise LoadError if ENV["DOTFILES_EXEC_MODE"] == "open3"

      require "posix/spawn"
      :posix_spawn
    rescue LoadError
      require "open3"
      :open3
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
      raise ExecutionError, stderr if failed?

      self
    end

    def method_missing(name, *args, &block)
      return super unless stdout.respond_to?(name)

      stdout.send(name, *args, &block)
    end

    def respond_to_missing?(name, include_all = false)
      stdout.respond_to?(name, include_all)
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

    if MODE == :open3
      def execute
        args = spawn_args.dup
        options = args.last
        options[:stdin_data] = options.delete(:input) if Hash === options && options.key?(:input)

        Open3.capture3(*spawn_args)
      end
    else
      def execute
        child = POSIX::Spawn::Child.build(*spawn_args)
        child.exec!

        [child.out, child.err, child.status]
      end
    end
  end
end
