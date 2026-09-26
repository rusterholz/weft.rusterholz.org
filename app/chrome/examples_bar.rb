# frozen_string_literal: true

require "active_support/core_ext/string/output_safety"
require "erb"

# The flat bar down the left of an example page: every example in the catalog,
# the running ones linked, the rest named so the whole shape of the section shows.
class ExamplesBar < Weft::Component
  builder_method :examples_bar

  receives :current

  def tag_name = "nav"

  def build(attributes = {})
    super(attributes.merge(class: "examples-bar", "aria-label": "UI Examples"))
    Catalog.entries.each { |entry| entry_for(entry) }
  end

  private

  def entry_for(entry)
    if entry.slug == params.current
      a entry.title, href: entry.path, class: "entry current", "aria-current": "page"
    elsif entry.live?
      a entry.title, href: entry.path, class: "entry"
    else
      # As one text node: Arbre indents a nested tag, and here the indent would show.
      span class: "entry coming" do
        text_node "#{ERB::Util.html_escape(entry.title)}<span class=\"visually-hidden\"> (coming)</span>".html_safe
      end
    end
  end
end
