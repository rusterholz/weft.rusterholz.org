# frozen_string_literal: true

# The base of the site's own components; the examples' stay on Weft::Component, as weft's docs write them.
class ApplicationComponent < Weft::Component
  abstract!

  # SiteData::Misassembled: weft's error fragment in place, a 500. A page target here would redirect.
  recovers from: SiteData::Misassembled, with: :error_component, status: 500
end
