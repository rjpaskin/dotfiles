require "delegate"

module ShellLib
  class App < SimpleDelegator
    attr_reader :name
    alias_method :path, :__getobj__

    def initialize(name)
      @name = name
      super(Path.new "/Applications/#{name}.app")
    end

    def executable
      @executable ||= path.join(
        "Contents/MacOS",
        self["CFBundleExecutable"]
      )
    end

    def [](key)
      info.fetch(key.to_s)
    end

    def archs
      Runner.current.archs(executable)
    end

    def info
      @info ||= path.join("Contents/Info.plist").as_plist
    end
  end
end
