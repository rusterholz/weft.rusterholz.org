# frozen_string_literal: true

# The placeholder front door. It becomes the examples index once there are
# examples to index.
class HomePage < ApplicationPage
  self.page_path = "/"

  title SITE_NAME

  def build(attributes = {})
    super
    h1 SITE_NAME
    para "Every example that ships with Weft, running live, beside the code that rendered it."
    para "The catalog is being built in the open. There is nothing here yet but this page."
    para { a "Weft on GitHub", href: WEFT_REPO_URL }
  end
end
