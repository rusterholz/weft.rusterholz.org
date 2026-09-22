# frozen_string_literal: true

# Replaces the gem's own not-found document (see config/environment.rb). The
# path is explicit because declaring a param opts a page out of name-derived
# routing, and it is addressable on purpose: a page you can only reach by
# breaking something is a page nobody restyles correctly.
class NotFoundPage < ApplicationPage
  self.page_path = "/_site/not_found"

  param :request_path, type: :string

  title "Not Found · #{SITE_NAME}"

  def build(attributes = {})
    super
    h1 "Not Found"
    para "There is nothing at #{params.request_path}."
    para { a "Back to the examples", href: "/" }
  end
end
