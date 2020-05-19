require "pathname"

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

  def include?(matcher)
    if matcher.is_a?(Regexp)
      content =~ matcher
    else
      read.include?(matcher)
    end
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

  private

  attr_reader :pathname
end
