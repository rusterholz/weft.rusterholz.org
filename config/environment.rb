# frozen_string_literal: true

APP_ROOT = File.expand_path("..", __dir__)

require "bundler/setup"
require "active_support" # the base, before app/data cherry-picks from it
require "weft"

# One weft version's examples are loadable at a time: the version this site runs.
# Move the pin without porting them and the boot says so: no such directory.
EXAMPLES_ROOT = File.join(APP_ROOT, "examples", "v#{Weft::VERSION.split('.').first(2).join('.')}")

WEFT_REPO_URL = "https://github.com/rusterholz/weft"
WEFT_CHANGELOG_URL = "#{WEFT_REPO_URL}/blob/v#{Weft::VERSION}/CHANGELOG.md".freeze
SITE_REPO_URL = "https://github.com/rusterholz/weft.rusterholz.org"

# Each directory under app/ is its own Zeitwerk root (app/pages/home_page.rb
# defines HomePage, not Pages::HomePage), and both calls eager-load, so the
# constants Weft.configure names below exist by then. app/data has a loader of its
# own and is never reloaded: the store's cache has to outlive a request.
Weft.configure_autoloading(paths: File.join(APP_ROOT, "app", "data"))

Weft.configure_autoloading(
  paths: [File.join(APP_ROOT, "app", "chrome"),
          File.join(APP_ROOT, "app", "pages"),
          EXAMPLES_ROOT],
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
