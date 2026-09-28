# frozen_string_literal: true

# The base of the site's own components. Code a page shows, the examples' and Glue's, stays on Weft::Component.
class ApplicationComponent < Weft::Component
  abstract!

  # SiteData::Misassembled: weft's error fragment, a 500, in place while htmx_errors is :fragment.
  recovers from: SiteData::Misassembled, with: :error_component, status: 500
end
