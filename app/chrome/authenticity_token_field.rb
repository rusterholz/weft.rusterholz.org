# frozen_string_literal: true

# The hidden field every form that writes carries: the session's CSRF token,
# which Rack::Protection::AuthenticityToken in config.ru checks on each POST.
# htmx sends a form's fields and so does a plain submit, so one field covers both.
class AuthenticityTokenField < Weft::Component
  builder_method :authenticity_token

  # Weft would give every field the one id its class name yields.
  def weft_dom_id = nil
  def tag_name = "input"

  def build(attributes = {})
    super(attributes.merge(type: "hidden", name: "authenticity_token", value: Current.csrf_token))
  end
end
