require "forwardable"
require "pathname"

module ShellLib
  class Path
    include Comparable
    extend Forwardable

    def_delegators :pathname,
      :directory?, :file?, :exist?,
      :executable?, :symlink?,
      :readable?, :world_readable?, :writable?,
      :extname, :read, :to_s

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
      when SearchPath::Entry
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

    def in?(other)
      to_s.start_with?(other.to_s)
    end

    alias_method :inside?, :in?

    HIDDEN_FLAG = 0x8000

    # See https://unix.stackexchange.com/a/438359
    def hidden?
      user_flags = Runner.current.command!("/usr/bin/stat -f '%Xf' '#{pathname}'")

      user_flags.to_i(16) & HIDDEN_FLAG != 0
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

    def as_json
      @json ||= JSON.parse(content, symbolize_names: true)
    end

    NIX_STORE_PATH = "/nix/store/".freeze

    def in_nix_store?
      inside?(NIX_STORE_PATH) || (symlink? && realpath.inside?(NIX_STORE_PATH))
    end

    def editable
      EditablePath.new(self)
    end

    def readonly
      Path.new(self)
    end

    private

    attr_reader :pathname
  end
end
