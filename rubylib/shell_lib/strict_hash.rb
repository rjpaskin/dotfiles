require "forwardable"
require "json"

module ShellLib
  class StrictHash
    extend Forwardable

    def_delegators :inner, :each_value

    def self.parse_json(string)
      JSON.parse(string, object_class: self)
    end

    def [](*keys)
      path = []

      keys.inject(inner) do |out, key|
        path << key
        out.fetch(key.to_s) do
          raise KeyError, "Path not found: #{path.join(".")}"
        end
      end
    end

    # Used by `JSON.parse`
    def []=(key, value)
      inner[key.to_s] = value
    end

    def fetch(*args, &block)
      duped = args.dup
      duped[0] = duped[0].to_s

      inner.fetch(*duped, &block)
    end

    def values_at(*keys)
      keys.map {|key| self[key] }
    end

    private

    def inner
      @inner ||= {}
    end
  end
end
