# frozen_string_literal: true

module SiteData
  # The site put together wrong, so only a developer meets one; each subclass says
  # what is missing. ApplicationPage recovers from it; components, weft's own edge.
  Misassembled = Class.new(StandardError)
end
