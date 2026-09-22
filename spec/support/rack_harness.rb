# frozen_string_literal: true

# Specs drive the assembled config.ru stack, not Weft::Router directly: the
# middleware is part of what every example works through, and cookies persisting
# across a spec's requests are what make one spec one visitor.
module RackHarness
  APP = Rack::Builder.parse_file(File.join(APP_ROOT, "config.ru"))

  def app = APP
end
