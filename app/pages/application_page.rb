# frozen_string_literal: true

# The document every page of this site renders inside. `abstract!` keeps it out
# of the route table, which Weft otherwise derives from the class name.
class ApplicationPage < Weft::Page
  abstract!

  SITE_NAME = "weft"

  # Moves into config with the rest of the external links when the chrome lands.
  WEFT_REPO_URL = "https://github.com/rusterholz/weft"

  register_script "js/htmx.min.js"
end
