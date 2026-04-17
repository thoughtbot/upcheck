# frozen_string_literal: true

require "upcheck"
require "webmock/rspec"
require_relative "support/fixtures"
require_relative "support/upcheck_helpers"
require_relative "support/shared_examples/provider_adapter"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include UpcheckHelpers

  config.before do
    Upcheck.reset!
  end
end
