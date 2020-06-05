require "pathname"

module ShellLib
  class Path
    include Comparable

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
      else
        raise ArgumentError, "could not compare #{other} with #{self.class}"
      end

      pathname <=> other_pathname
    end

    %i[directory? file? executable? symlink? readable? writable? extname read to_s].each do |method|
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def #{method}(*args); pathname.#{method}(*args); end
      RUBY
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

    def include?(matcher)
      if matcher.is_a?(Regexp)
        content =~ matcher
      else
        read.include?(matcher)
      end
    end

    def blank?
      content =~ /\A\s*\z/
    end

    def empty?
      if directory?
        children.none?
      elsif file?
        blank?
      end
    end

    def in?(other)
      to_s.start_with?(other.to_s)
    end

    alias_method :inside?, :in?

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

    NIX_STORE_PATH = "/nix/store/".freeze

    def in_nix_store?
      symlink? && realpath.to_s.start_with?(NIX_STORE_PATH)
    end

    private

    attr_reader :pathname
  end
end
