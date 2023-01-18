module ShellLib
  module ResourceHelpers
    Runner.instance_methods(false).each do |method|
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def #{method}(*args, &block)
          Runner.current.#{method}(*args, &block)
        end
      RUBY
    end
  end
end
