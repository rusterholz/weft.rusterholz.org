# frozen_string_literal: true

# The header across the top of every page: where you are, on the left, and the
# site-wide widgets, borderless, on the right.
class SiteHeader < Weft::Component
  builder_method :site_header

  receives :trail

  def tag_name = "header"

  def build(attributes = {})
    super(attributes.merge(class: "site-header"))
    crumbs trail: params.trail
    div class: "widgets" do
      a "GitHub", href: WEFT_REPO_URL, class: "flat"
    end
  end
end
