require "delegate"

module ShellLib
  class Resource < SimpleDelegator
    attr_reader :name

    def initialize(name, &block)
      @name = name
      @block = block
    end

    def to_s
      name.to_s
    end

    def __getobj__
      __setobj__(block.call) unless defined?(@__called)
      @__called = true
      super
    end

    def inspect
      "#<#{name} #{__getobj__.inspect}>"
    end

    private

    attr_reader :block
  end
end
