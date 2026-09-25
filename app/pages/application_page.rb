# frozen_string_literal: true

require "active_support/core_ext/string/filters"

# The document every page renders inside; abstract! keeps it out of the route table Weft derives from class names.
class ApplicationPage < Weft::Page
  abstract!

  SITE_NAME = "weft"

  # Move into config with the rest of the external links when the chrome lands.
  WEFT_REPO_URL = "https://github.com/rusterholz/weft"
  SITE_REPO_URL = "https://github.com/rusterholz/weft.rusterholz.org"

  register_script "js/htmx.min.js"

  private

  # A heredoc as paragraphs, split at blank lines, each free to wrap in the source. Plain text only.
  def prose(text)
    text.split(/\n\s*\n/).map(&:squish).reject(&:empty?).each { |paragraph| para paragraph }
  end

  # Source files travel as paths inside this repo: shown, linked and read as one.
  def repo_path(absolute_path) = Pathname.new(absolute_path).relative_path_from(APP_ROOT).to_s

  # GIT_SHA is baked in at image build, so a deployed page links the code it runs.
  def source_url(repo_path) = "#{SITE_REPO_URL}/blob/#{ENV.fetch('GIT_SHA', 'main')}/#{repo_path}"
end
