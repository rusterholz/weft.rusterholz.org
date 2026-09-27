# frozen_string_literal: true

# The hidden field every form that writes carries: the session's CSRF token,
# which Rack::Protection::AuthenticityToken in config.ru checks on each POST.
# htmx sends a form's fields and so does a plain submit, so one field covers both.
class AuthenticityTokenField < Weft::Component
  extend SiteHelper

  builder_method :authenticity_token
  describes "the hidden field that carries the visitor's CSRF token, in every form that writes"

  # No id, since weft would give every field the same one; tag_name is Arbre's hook for the element's tag.
  def weft_dom_id = nil
  def tag_name = "input"

  def build(attributes = {})
    super(attributes.merge(type: "hidden", name: "authenticity_token", value: Current.csrf_token))
  end
end
