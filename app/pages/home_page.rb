# frozen_string_literal: true

# The front door, and the UI Examples index: a short pitch, then every example
# in the catalog, the running ones linked and the rest marked as coming.
class HomePage < ApplicationPage
  self.page_path = "/"

  title SITE_NAME

  def build(attributes = {})
    super
    h1 "UI Examples"
    pitch
    ol(class: "index") { Catalog.entries.each { |entry| li { listing(entry) } } }
  end

  private

  def trail = [[SITE_NAME, "/"], ["UI Examples", nil]]

  def pitch
    prose <<~TEXT
      Every example that ships with Weft, running live, beside the code that rendered it.

      If you know the server side and want to see what htmx is doing, the margin of each page
      lists the declarations that wire it; if you know the front end and want to see what Arbre
      is, the Ruby that built the markup sits right below.

      Click the thing, then read what made it happen.
    TEXT
  end

  def listing(entry)
    if entry.live?
      a(href: entry.path) { span entry.title, class: "title" }
    else
      span entry.title, class: "title"
      span "coming", class: "coming"
    end
    span entry.summary, class: "summary"
  end
end
