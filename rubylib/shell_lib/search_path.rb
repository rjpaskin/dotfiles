module ShellLib
  class SearchPath
    Entry = Struct.new(:path, :index) do
      def inspect
        "#{path.inspect}@#{index}"
      end

      def pretty_print(pp)
        pp.text(inspect)
      end

      def present?
        index > NULL_ENTRY.index
      end

      def before?(other)
        index < other.index
      end

      def after?(other)
        index > other.index
      end

      def ===(other)
        case other
        when Regexp
          other.match?(path.to_s)
        when String, Path
          path == other
        else
          raise ArgumentError
        end
      end
    end

    NULL_ENTRY = Entry.new("<not found>", -1)

    def self.parse(text)
      new(text.split ":")
    end

    def initialize(entries)
      @entries = entries.each_with_index.map do |entry, index|
        Entry.new(Path.new(entry), index)
      end.freeze
    end

    def each(&block)
      entries.each(&block)
    end

    def [](value)
      case value
      when Numeric
        entries[value] || NULL_ENTRY
      when String, Path
        entries.find {|entry| entry.path == value } || NULL_ENTRY
      else
        raise ArgumentError
      end
    end

    def include?(matcher)
      entries.any? {|entry| entry === matcher }
    end

    def has_entry?(matcher, at: nil)
      return include?(matcher) unless at

      at === self[matcher].index
    end

    def pretty_print(pp)
      pp.pp(entries)
    end

    def empty?
      entries.empty?
    end

    private

    attr_reader :entries
  end
end
