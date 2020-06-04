require "open3"

module ShellLib
  class Command
    class ExecutionError < StandardError; end

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

    %i[success?].each do |method|
      class_eval <<~RUBY
        def #{method}; status.#{method}; end
      RUBY
    end

    def failed?
      !success?
    end

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

    def open3_args
      command
    end

    def run
      return if run?

      stdout, @stderr, @status = Open3.capture3(*open3_args)
      @stdout = Output.new(stdout)
    end

    def run?
      defined?(@status) && @status.is_a?(Process::Status)
    end
  end
end
