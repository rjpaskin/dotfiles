module ShellLib
  class Program
    attr_reader :name, :cmds

    MACH_MIME_TYPE = "application/x-mach-binary".freeze

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
      Runner.current.archs(native_executable_path)
    end

    def native_executable_path
      current_path = path

      5.times do
        mime = Runner.current.mime_type(current_path)

        case mime
        when MACH_MIME_TYPE
          return current_path
        when "text/plain"
          wrapped = current_path.content[/\bexec\s+(?:-a\s+"?\$0"?\s+)?"?([a-z0-9\/.\-_]+)/, 1]
          raise "Couldn't extract wrapped executable from #{current_path}" unless wrapped

          current_path = Path.new(wrapped.chomp('"'))
        else
          raise "Unknown mime type: #{mime} for #{current_path}"
        end
      end

      raise "Exceeded depth for unwrapping wrapper for #{inspect}"
    end
  end
end
