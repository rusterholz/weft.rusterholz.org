# frozen_string_literal: true

source "https://rubygems.org"

ruby file: ".ruby-version"

# Pinned exactly, and only a deliberate floor-bump mission moves it. This site
# is weft's first consumer from outside the gem's own repo, so it is worth
# something only while it builds against a released version the way anyone else
# would -- never a path, a git ref, or the dev branch.
gem "weft", "0.2.0"

gem "activesupport" # app/data uses its cache and CurrentAttributes; weft's floor governs the version
gem "puma", "~> 7.2"
gem "rack-session", "~> 2.1" # Rack::Session::Cookie, the session seam
gem "rouge", "~> 5.1"        # server-side highlighting for the code each example shows

group :development, :test do
  gem "nokogiri", "~> 1.18"
  gem "rack-test", "~> 2.1"
  gem "rspec", "~> 3.13"
  gem "rubocop", "~> 1.66"
  gem "rubocop-rake", "~> 0.6"
  gem "rubocop-rspec", "~> 3.0"
end
