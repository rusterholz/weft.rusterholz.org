# frozen_string_literal: true

APP_ROOT = File.expand_path("..", __dir__)

require "bundler/setup"
require "active_support" # the base, before app/data cherry-picks from it
require "weft"
require "zeitwerk"

# One weft version's examples are loadable at a time: the version this site runs.
# Move the pin without porting them and the boot says so: no such directory.
EXAMPLES_ROOT = File.join(APP_ROOT, "examples", "v#{Weft::VERSION.split('.').first(2).join('.')}")

WEFT_REPO_URL = "https://github.com/rusterholz/weft"
WEFT_CHANGELOG_URL = "#{WEFT_REPO_URL}/blob/v#{Weft::VERSION}/CHANGELOG.md".freeze
SITE_REPO_URL = "https://github.com/rusterholz/weft.rusterholz.org"

# The site's own support code, apart from anything weft: app/data/store.rb
# defines SiteData::Store. Never reloaded, since the store's cache has to outlive
# a request. A plain loader because weft 0.2's configure_autoloading takes no namespace.
module SiteData; end

data_loader = Zeitwerk::Loader.new
data_loader.push_dir(File.join(APP_ROOT, "app", "data"), namespace: SiteData)
data_loader.setup
data_loader.eager_load

# Each other directory is a root with no namespace (app/pages/home_page.rb
# defines HomePage, not Pages::HomePage), and the call eager-loads, so the
# constants Weft.configure names below exist by then.
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
