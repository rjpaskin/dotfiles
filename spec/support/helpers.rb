require_relative "./runner"

module ResourceHelpers
  Runner.instance_methods(false).each do |method|
    class_eval <<~RUBY, __FILE__, __LINE__ + 1
      def #{method}(*args, &block)
        Runner.current.#{method}(*args, &block)
      end
    RUBY
  end
end

RSpec.configure do |config|
  config.extend ResourceHelpers
  config.include ResourceHelpers

  config.before(:each, :role) do |example|
    role = example.metadata[:role]

    skip("role '#{role}' is disabled") unless role_enabled?(role)
  end
end
