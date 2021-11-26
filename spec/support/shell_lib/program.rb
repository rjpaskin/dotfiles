module ShellLib
  class Program
    attr_reader :name, :cmds

    def initialize(name)
      @name = name
      @cmds = Hash.new do |cache, cmd|
        cache[cmd] = Runner.current.run_in_shell!("command #{name} #{cmd}")
      end
    end

    def path
      @path ||= Runner.current.which(name)
    end

    def location
      path.dirname
    end

    def inspect
      "#<Program #{name}>"
    end

    alias_method :to_s, :inspect

    def content
      path.content
    end

    def method_missing(method, *args, &block)
      if method.to_s.start_with?("--")
        cmds[method]
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      name.to_s.start_with?("--") || super
    end

    def manpage
      Runner.current.manpage(name)
    end

    def archs
      Runner.current.archs(path)
    end
  end
end
