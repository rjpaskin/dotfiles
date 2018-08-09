module GitCI
  class JSONStruct
    attr_reader :data

    def self.accessors(*keys)
      if keys.any?
        @accessors = keys
        attr_reader *keys
      else
        @accessors ||= []
      end
    end

    def initialize(data)
      @data = data

      self.class.accessors.each do |key|
        instance_variable_set("@#{key}", data[key])
      end
    end
  end
end
