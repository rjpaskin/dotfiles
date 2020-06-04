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

    def pretty_print(pp)
      pp.pp(entries)
    end

    private

    attr_reader :entries
  end
end
