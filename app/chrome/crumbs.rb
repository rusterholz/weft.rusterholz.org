# frozen_string_literal: true

# The breadcrumb that opens every page's header, wordmark first. Each step is a
# label and a path; the last is the page itself, named but not linked, unless
# it is the wordmark, which is always the way home.
class Crumbs < ApplicationComponent
  builder_method :crumbs

  receives :trail

  def tag_name = "nav"

  def build(attributes = {})
    super(attributes.merge("aria-label": "Breadcrumb"))
    earlier_steps = params.trail[0...-1]
    current_label = params.trail.last.first

    earlier_steps.each_with_index do |(label, href), index|
      a label, href: href, class: ("wordmark" if index.zero?)
      span "/", class: "crumb-divider", "aria-hidden": "true"
    end

    if earlier_steps.empty?
      a current_label, href: "/", class: "wordmark"
    else
      span current_label, "aria-current": "page"
    end
  end
end
