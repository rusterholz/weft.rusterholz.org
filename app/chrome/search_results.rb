# frozen_string_literal: true

# What the header's search finds: catalog entries whose title or summary holds
# the typed text. The running examples link; the rest are named as coming.
class SearchResults < Weft::Component
  builder_method :search_results

  param :q, default: ""
  derives(:query) { |p| p.q.to_s.strip }
  derives(:matches) { |p| Catalog.matching(p.query) }

  # Weft would suffix the id with the query itself, typed by anyone.
  def weft_dom_id = "search-results"

  def build(attributes = {})
    super
    return if params.query.empty?

    if params.matches.empty?
      para "No example matches \"#{params.query}\"."
    else
      ul { params.matches.each { |entry| li { hit(entry) } } }
    end
  end

  private

  def hit(entry)
    if entry.live?
      a(href: entry.path) { description(entry) }
    else
      span(class: "coming") { description(entry, coming: true) }
    end
  end

  def description(entry, coming: false)
    span entry.title, class: "title"
    span coming ? "coming" : entry.summary, class: "summary"
  end
end
