require "Forwardable"

module ShellLib
  class Program
    extend Forwardable

    attr_reader :name, :cmds

    MACH_MIME_TYPE = "application/x-mach-binary".freeze

    def_delegators :path, :dirname, :content, :in_nix_store?

    alias_method :location, :dirname

    def initialize(name)
      @name = File.basename(name.to_s)

      @has_full_path = name.to_s.start_with?("/")
      @path = Path.new(name) if @has_full_path

      @cmds = Hash.new do |cache, cmd|
        cache[cmd] = Runner.current.run_in_shell!("command #{@path || name} #{cmd}")
      end
    end

    def path
      @path ||= Runner.current.which(name) or raise Errno::ENOENT, name
    end

    def running?
      Runner.current.command(
        "/usr/bin/pgrep -xq #{@has_full_path ? "-f #{@path}" : name}"
      ).success?
    end

    def inspect
      "#<Program #{@has_full_path ? @path : name}>"
    end

    alias_method :to_s, :inspect

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
