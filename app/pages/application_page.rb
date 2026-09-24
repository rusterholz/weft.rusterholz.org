# frozen_string_literal: true

# The document every page of this site renders inside. `abstract!` keeps it out
# of the route table, which Weft otherwise derives from the class name.
class ApplicationPage < Weft::Page
  abstract!

  SITE_NAME = "weft"

  # Move into config with the rest of the external links when the chrome lands.
  WEFT_REPO_URL = "https://github.com/rusterholz/weft"
  SITE_REPO_URL = "https://github.com/rusterholz/weft.rusterholz.org"

  register_script "js/htmx.min.js"

  private

  def relative_path(absolute_path) = Pathname.new(absolute_path).relative_path_from(APP_ROOT).to_s

  # GIT_SHA is baked in at image build, so a deployed page links the code it runs.
  def source_url(absolute_path)
    "#{SITE_REPO_URL}/blob/#{ENV.fetch('GIT_SHA', 'main')}/#{relative_path(absolute_path)}"
  end
end
