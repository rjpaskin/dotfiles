require "delegate"

module ShellLib
  class Program < SimpleDelegator
    attr_reader :name, :cmds

    def initialize(name)
      @name = name
      @cmds = Hash.new do |cache, cmd|
        cache[cmd] = Runner.current.run_in_shell!("command #{name} #{cmd}")
      end
    end

    def __getobj__
      __setobj__(Runner.current.which name) unless defined?(@__loaded)
      @__loaded = true
      super
    end

    alias_method :path, :__getobj__

    def location
      __getobj__.dirname
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
  end
end
