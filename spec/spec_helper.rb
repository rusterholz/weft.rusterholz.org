# frozen_string_literal: true

# Without this, Sinatra boots in development mode, whose host protection answers
# every Rack::Test request 403 before it reaches the app.
ENV["RACK_ENV"] ||= "test"

# A throwaway key, assigned unconditionally so an exported secret cannot leak
# into a test run. See docs/development.md, "The Session Secret Is Not a CI Secret".
ENV["SESSION_SECRET"] = "test-only-not-a-secret".ljust(64, "0")

require "rack/test"

require_relative "../config/environment"

Dir[File.join(APP_ROOT, "spec", "support", "**", "*.rb")].each { |file| require file }

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include RackHarness

  config.disable_monkey_patching!
  config.expect_with(:rspec) { |expectations| expectations.syntax = :expect }
end
