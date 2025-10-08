require "delegate"
require "forwardable"
require "pathname"
require "shellwords"
require "uri"
require "yaml"

module ShellLib
  class Path
    include Comparable
    extend Forwardable

    def_delegators :pathname,
      :directory?, :file?, :exist?,
      :executable?, :symlink?,
      :readable?, :world_readable?, :writable?,
      :extname, :read, :to_s

    alias_method :exists?, :exist?

    def self.from_uri(uri)
      new(CGI.unescape URI.parse(uri.to_s).path)
    end

    def initialize(path)
      @pathname = Pathname(path).expand_path
    end

    def <=>(other)
      other_pathname = case other
      when self.class
        other.send(:pathname)
      when Pathname
        other
      when String
        Pathname(other).expand_path
      when SearchPath::Entry, App
        Pathname(other.path).expand_path
      else
        raise ArgumentError, "could not compare #{other} with #{self.class}"
      end

      pathname <=> other_pathname
    end

    def only_user_readable?
      !world_readable?
    end

    alias_method :to_str, :to_s

    %i[realpath dirname basename join].each do |method|
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def #{method}(*args); self.class.new(pathname.#{method}(*args)); end
      RUBY
    end

    %i[glob children].each do |method|
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def #{method}(*args)
          pathname.#{method}(*args).map {|path| self.class.new(path) }
        end
      RUBY
    end

    def basename_str(*args)
      File.basename(pathname, *args)
    end

    def include?(matcher)
      if matcher.is_a?(Regexp)
        matcher.match?(content)
      else
        content.include?(matcher)
      end
    end

    alias_method :matches?, :include?

    def blank?
      matches?(/\A\s*\z/)
    end

    def has_content?
      !blank?
    end

    def empty?
      if directory?
        children.none?
      elsif file?
        blank?
      end
    end

    def absent?
      !exist?
    end

    def exist!
      raise Errno::ENOENT, to_s if absent?

      block_given? ? yield : self
    end

    def in?(other)
      to_s.start_with?(other.to_s)
    end

    alias_method :inside?, :in?

    HIDDEN_FLAG = 0x8000

    # See https://unix.stackexchange.com/a/438359
    def hidden?
      exist! do
        user_flags = Runner.current.command!("/usr/bin/stat -f '%Xf' '#{pathname}'")
        user_flags.to_i(16) & HIDDEN_FLAG != 0
      end
    end

    def has_xattr?(name, recursive: false)
      exist! do
        cmd = ["xattr", *("-r" if recursive), name, "'#{pathname}'"]

        Runner.current.command(cmd.join " ").lines.any? do |line|
          line.end_with?(name)
        end
      end
    end

    QUARANTINE_XATTR = "com.apple.quarantine"

    def quarantined?
      has_xattr?(QUARANTINE_XATTR, recursive: true)
    end

    def inspect
      "#<Path #{pathname.to_s}>"
    end

    def content
      @content ||= read
    end

    alias_method :contents, :content

    def lines
      @lines ||= content.split(/\r?\n/)
    end

    def as_json(**options)
      @json ||= JSON.parse(content, symbolize_names: true, **options)
    end

    alias_method :json_content, :as_json

    def as_plist
      @plist ||= Plist.load_file(pathname)
    end

    alias_method :plist_content, :as_plist

    def as_yaml
      @yaml ||= YAML.load(content)
    end

    alias_method :yaml_content, :as_yaml

    def as_ini
      @ini ||= INI.load_file(pathname)
    end

    alias_method :ini_content, :as_ini

    NIX_STORE_PATH = "/nix/store/".freeze

    def in_nix_store?
      inside?(NIX_STORE_PATH) || (symlink? && realpath.inside?(NIX_STORE_PATH))
    end

    def mach_binary?
      Runner.current.mime_type(self) == Program::MACH_MIME_TYPE
    end

    class Shebang < SimpleDelegator
      ENV = Path.new("/usr/bin/env").freeze

      attr_reader :command, :args

      def self.from(raw)
        command, *args = Shellwords.split(raw)

        new(Path.new(command), args)
      end

      def initialize(command, args)
        @command = command
        @args = args

        super(Program.new(env? ? args.first : command))
      end

      def env?
        command == ENV
      end

      def inspect
        "#<#{self.class} #{__getobj__.inspect}>"
      end
    end

    def shebang
      Shebang.from(
        (lines.first[/^#! *(.+)$/, 1] or raise ArgumentError, "#{to_s} has no shebang")
      )
    end

    def becomes(klass)
      klass.new(self)
    end

    def editable
      becomes(EditablePath)
    end

    def readonly
      becomes(Path)
    end

    private

    attr_reader :pathname
  end
end
