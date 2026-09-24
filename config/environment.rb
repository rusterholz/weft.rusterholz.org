# frozen_string_literal: true

APP_ROOT = File.expand_path("..", __dir__)

require "bundler/setup"
require "active_support" # the base, before app/data cherry-picks from it
require "weft"

# Each directory under app/ is its own Zeitwerk root, so app/pages/home_page.rb
# defines HomePage, not Pages::HomePage. This runs before Weft.configure because
# it loads eagerly: the constants configured below have to exist by then.
Weft.configure_autoloading(
  paths: [File.join(APP_ROOT, "app", "data"),
          File.join(APP_ROOT, "app", "pages")],
  reload: ENV.fetch("RACK_ENV", "production") == "development"
)

Weft.configure do |c|
  c.static_assets root: "/static", from: File.join(APP_ROOT, "public")

  # Nothing the running site loads comes from a third party, htmx included;
  # bin/fetch-htmx vendors both files into public/js.
  c.include_htmx = false
  c.include_sse_ext = false

  c.error_page = ErrorPage
  c.not_found_page = NotFoundPage

  c.verbose_error_pages = ENV.fetch("RACK_ENV", "production") != "production"
end
