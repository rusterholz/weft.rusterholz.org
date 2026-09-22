# frozen_string_literal: true

# Replaces the gem's own error document, via `error_page` in
# config/environment.rb.
#
# `verbose_error_pages` is a setting the gem honors in its own fallbacks and
# leaves to you in yours, so this page reads it rather than assuming: detail in
# development, nothing leaked in production.
class ErrorPage < ApplicationPage
  self.page_path = "/_site/error"

  param :exception
  param :status_code, type: :integer

  title "Something Went Wrong · #{SITE_NAME}"

  def build(attributes = {})
    super
    h1 "Something Went Wrong"
    para "This page could not be rendered."
    detail if Weft.configuration.verbose_error_pages
    para { a "Back to the examples", href: "/" }
  end

  private

  def detail
    error = params.exception
    return if error.nil?

    para { code "#{error.class}: #{error.message}" }
  end
end
