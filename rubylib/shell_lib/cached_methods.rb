module ShellLib
  module CachedMethods
    def self.extended(base)
      base.instance_eval do
        class << self
          attr_reader :cache_blocks
        end

        @cache_blocks = {}
      end
    end

    def define_cached_method(name, key_optional: false, &block)
      @cache_blocks[name.to_sym] = block
      escaped_name = name.to_s.sub(/[!?]$/, "")

      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def #{escaped_name}_cache
          @#{escaped_name}_cache ||= begin
            block = self.class.cache_blocks.fetch(:#{name})

            Hash.new do |cache, value|
              cache[value] = instance_exec(value, &block)
            end
          end
        end

        private :#{escaped_name}_cache

        def #{name}(value#{" = nil" if key_optional})
          #{escaped_name}_cache[value]
        end
      RUBY
    end
  end
end
