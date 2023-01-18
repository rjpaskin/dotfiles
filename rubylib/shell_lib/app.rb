require "forwardable"

module ShellLib
  class App
    extend Forwardable
    def_delegators :path, :exist?, :quarantined?

    attr_reader :name

    SYSTEM = Path.new("/System")

    def initialize(name)
      @name = name
    end

    def path
      @path ||= begin
        path = Path.new("/Applications/#{name}.app")

        if ShellLib.macos_version < :big_sur
          path
        else
          system_path = SYSTEM.join("Applications", "#{name}.app")
          system_path.directory? ? system_path : path
        end
      end
    end

    alias_method :location, :path

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

    def inspect
      "#<App #{name}.app>"
    end

    alias_method :to_s, :inspect
  end
end
