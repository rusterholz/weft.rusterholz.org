# frozen_string_literal: true

require "active_support/core_ext/string/output_safety"

# The header's search pill. It is weft's Active Search example at work on the
# site's own catalog: `live_search:` asks SearchResults for matches as the
# visitor types and fills the panel under the field. The panel shows while the
# search has focus or the pointer is over it, which is how it closes without a
# script.
class SiteSearch < Weft::Component
  builder_method :site_search

  MAGNIFIER = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" ' \
              'stroke-width="2" aria-hidden="true"><circle cx="11" cy="11" r="7"></circle>' \
              '<path d="M20 20l-3.5-3.5"></path></svg>'

  def build(attributes = {})
    super(attributes.merge(class: "site-search"))
    label class: "pill" do
      text_node MAGNIFIER.html_safe
      input type: "search", name: "q", placeholder: "Search", autocomplete: "off",
            "aria-label": "Search the examples",
            live_search: SearchResults, with: {}, target: "#site-search-results"
    end
    div id: "site-search-results", class: "search-panel"
  end
end
