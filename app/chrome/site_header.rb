# frozen_string_literal: true

# The header across the top of every page: where you are, on the left, and the
# site-wide widgets, borderless, on the right.
class SiteHeader < Weft::Component
  builder_method :site_header

  receives :trail
  receives :return_to

  def tag_name = "header"

  def build(attributes = {})
    super(attributes.merge(class: "site-header"))
    crumbs trail: params.trail
    div class: "widgets" do
      Theme::CHOICES.reverse_each { |theme| theme_toggle theme: theme, return_to: params.return_to }
      a "GitHub", href: WEFT_REPO_URL, class: "flat"
    end
  end
end
