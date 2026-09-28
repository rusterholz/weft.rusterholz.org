# frozen_string_literal: true

# The strip held along the foot of the window on every page, in the bench tone:
# anything that touches the wire sits here. The request line shows the visitor's
# last request, written by the site's script; hidden until that script reveals
# it, since without the script nothing would ever fill it.
class Bench < ApplicationComponent
  builder_method :bench

  receives :source_path
  derives(:source_href) { |p| SiteData::Source.url(p.source_path) }

  def tag_name = "footer"

  def build(attributes = {})
    super(attributes.merge("aria-label": "Bench"))
    add_class "bench"
    span "Your requests show here as you click.", class: "bench-request", hidden: true, "data-reveal": true
    a "weft #{Weft::VERSION}", href: WEFT_CHANGELOG_URL
    a "Open the Hood: #{params.source_path}", href: params.source_href, class: "hood"
  end
end
