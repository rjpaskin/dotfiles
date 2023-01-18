begin
  previous = $VERBOSE
  $VERBOSE = 0
  require "cfpropertylist"
ensure
  $VERBOSE = previous
end

module ShellLib
  module Plist
    class << self
      def parse(text)
        plist_to_ruby(data: text)
      end

      def load_file(path)
        plist_to_ruby(file: path)
      end

      private

      def plist_to_ruby(options)
        CFPropertyList.native_types(
          CFPropertyList::List.new(options).value
        )
      end
    end
  end
end
