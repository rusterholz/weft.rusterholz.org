# frozen_string_literal: true

# The strip along the foot of every page, in the bench tone: anything that
# touches the wire sits here. The request line is a place held for the last
# request a visitor makes; the site fills it once pages report their traffic.
class Bench < Weft::Component
  builder_method :bench

  receives :source_path

  def tag_name = "footer"

  def build(attributes = {})
    super(attributes.merge(class: "bench", "aria-label": "Bench"))
    span class: "bench-request"
    a "weft #{Weft::VERSION}", href: WEFT_CHANGELOG_URL
    a "Open the Hood: #{params.source_path}", href: Source.url(params.source_path), class: "hood"
  end
end
