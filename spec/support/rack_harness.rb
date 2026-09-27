# frozen_string_literal: true

require "nokogiri"

# Specs drive the assembled config.ru stack, not Weft::Router directly: the
# middleware is part of what every example works through, and cookies persisting
# across a spec's requests are what make one spec one visitor.
module RackHarness
  APP = Rack::Builder.parse_file(File.join(APP_ROOT, "config.ru"))

  def app = APP

  # The CSRF token read off a page, as a browser gets it; a POST without it is refused.
  def csrf_token
    get "/"
    Nokogiri::HTML5(last_response.body).at("input[name=authenticity_token]")["value"]
  end

  def post_form(path, fields = {}, headers = {})
    post path, fields.merge(authenticity_token: csrf_token), headers
  end
end
