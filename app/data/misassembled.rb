# frozen_string_literal: true

module SiteData
  # The site put together wrong, so only a developer meets one; each subclass says
  # what is missing. Weft's built-in StandardError edges answer it with a 500.
  Misassembled = Class.new(StandardError)
end
