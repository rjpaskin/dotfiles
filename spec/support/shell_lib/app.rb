require "delegate"

module ShellLib
  class App < SimpleDelegator
    attr_reader :name
    alias_method :path, :__getobj__

    def initialize(name)
      @name = name
      super(Path.new "/Applications/#{name}.app")
    end

    # Assume executable has the same name as the app
    def executable
      @executable ||= path.join("Contents/MacOS/#{name}")
    end

    def archs
      Runner.current.archs(executable)
    end
  end
end
