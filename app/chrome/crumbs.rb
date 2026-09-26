# frozen_string_literal: true

# The breadcrumb that opens every page's header, wordmark first. Each step is a
# label and a path; the last is the page itself, named but not linked, unless
# it is the wordmark, which is always the way home.
class Crumbs < Weft::Component
  builder_method :crumbs

  receives :trail

  def tag_name = "nav"

  def build(attributes = {})
    super(attributes.merge("aria-label": "Breadcrumb"))
    *path, (here,) = params.trail
    path.each_with_index do |(label, href), index|
      a label, href: href, class: ("wordmark" if index.zero?)
      span "/", class: "crumb-divider", "aria-hidden": "true"
    end
    path.empty? ? a(here, href: "/", class: "wordmark") : span(here, "aria-current": "page")
  end
end
