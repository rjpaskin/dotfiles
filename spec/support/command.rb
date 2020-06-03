require "open3"

class Command
  class ExecutionError < StandardError; end

  class Output < String
    def split(*args)
      super.map! {|line| self.class.new(line) }
    end

    def ==(other)
      return super(other.to_s) if other.is_a?(Path)

      super
    end

    def lines
      split(/\r?\n/)
    end

    def line
      lines.first
    end

    def as_vars(separator: "=")
      lines.each_with_object({}) do |line, env|
        name, value = line.split(separator, 2)
        env[name] = value.gsub(/(^'|'$)/, "") # strip surrounding quotes
      end
    end

    def as_path
      Path.new(line)
    end

    def as_search_path
      line.split(":").map(&:as_path)
    end

    def as_json
      JSON.parse(self, symbolize_names: true)
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
