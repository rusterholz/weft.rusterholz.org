# frozen_string_literal: true

# The front door. It grows into the full index, with the catalog's summaries and
# the ones still to come, when the site gets its design.
class HomePage < ApplicationPage
  self.page_path = "/"

  title SITE_NAME

  def build(attributes = {})
    super
    h1 SITE_NAME
    para "Every example that ships with Weft, running live, beside the code that rendered it."
    para "The catalog is being built in the open. These are running so far:"
    ul do
      Catalog.entries.select(&:live?).each { |entry| li { a entry.title, href: entry.path } }
    end
    para { a "Weft on GitHub", href: WEFT_REPO_URL }
  end
end
