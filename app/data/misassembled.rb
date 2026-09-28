# frozen_string_literal: true

module SiteData
  # The site put together wrong; each subclass says what is missing. ApplicationPage and ApplicationComponent
  # recover from it, while an example's own fragment lands on weft's built-in edge: docs/development.md,
  # "When the Site Is Wired Wrong".
  Misassembled = Class.new(StandardError)
end
