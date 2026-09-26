# frozen_string_literal: true

require "active_support/core_ext/string/filters"

# The document every page renders inside: the header, the page's own content in
# <main>, and the bench along the foot. abstract! keeps it out of the route table
# Weft derives from class names.
#
# The visitor's theme goes on <html>, and only when they have chosen one:
# without it the stylesheet follows the system setting, which the server cannot see.
class ApplicationPage < Weft::Page
  abstract!

  SITE_NAME = "weft"

  register_stylesheet "css/site.css"
  register_script "js/htmx.min.js"

  adds_children_to :@content

  def build(attributes = {})
    super(attributes.merge("data-theme": Theme.current).compact)
    site_header trail: trail, return_to: Current.request&.fullpath || "/"
    @content = main(class: "single-column")
    within(@content.parent) { bench source_path: page_source_path }
  end

  private

  def trail = [[SITE_NAME, "/"]]

  # The file that defines the page, which is what "open the hood" opens.
  def page_source_path = repo_path(self.class.instance_method(:build).source_location.first)

  # A heredoc as paragraphs, split at blank lines, each free to wrap in the source. Plain text only.
  def prose(text)
    text.split(/\n\s*\n/).map(&:squish).reject(&:empty?).each { |paragraph| para paragraph }
  end

  def repo_path(absolute_path) = Source.path_of(absolute_path)

  def source_url(repo_path) = Source.url(repo_path)
end
