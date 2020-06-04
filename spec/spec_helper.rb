require "rspec/its"

$LOAD_PATH << File.expand_path("./support", __dir__)
require "shell_lib"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # config.mock_with :rspec do |mocks|
  #   mocks.verify_partial_doubles = true
  # end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random

  Kernel.srand config.seed

  config.extend ShellLib::ResourceHelpers
  config.include ShellLib::ResourceHelpers
  config.extend ShellLib::PathHelpers
  config.include ShellLib::PathHelpers

  config.before(:each, :role) do |example|
    role = example.metadata[:role]

    skip("role '#{role}' is disabled") unless role_enabled?(role)
  end
end
