# frozen_string_literal: true

require "active_support/core_ext/string/inflections"

# The site's table of contents: weft's documented examples, in weft's own order,
# which is also the order the site walks them in.
#
# The titles and summaries are weft's, carried over near-verbatim so the site and
# the gem's docs name the same things the same way. Slugs match the filenames
# under weft's docs/examples, so a reader moving between the two navigates by the
# same words.
class Catalog
  Entry = Data.define(:slug, :title, :summary) do
    def path = "/examples/#{slug}"

    # Asking the page classes beats keeping a list, which could say yes to a
    # page that is not there.
    def live? = Object.const_defined?("#{slug.tr('-', '_').camelize}Page")
  end

  Unknown = Class.new(StandardError)

  ENTRIES = [
    Entry["click-to-edit", "Click to Edit", "Swap a read-only view for an edit form in place -- transfers"],
    Entry["edit-row", "Edit Row", "The same pattern per table row"],
    Entry["delete-row", "Delete Row", "Remove a row with a confirmation -- dismisses"],
    Entry["bulk-update", "Bulk Update", "One form updating many rows -- performs + array params"],
    Entry["inline-validation", "Inline Validation", "Per-field validation as the user types -- performs + recovers"],
    Entry["file-upload", "File Upload", "Multipart upload through a component action"],
    Entry["reset-user-input", "Reset User Input", "Clearing a form after submit -- free in Weft"],
    Entry["click-to-load", "Click to Load", "Load the next page of rows on demand -- load_more:"],
    Entry["lazy-loading", "Lazy Loading", "Defer expensive content until it's visible -- lazy:"],
    Entry["infinite-scroll", "Infinite Scroll", "Rows that keep coming as you scroll -- infinite_scroll:"],
    Entry["inline-expansion", "Inline Expansion", "Expand a row's detail in place -- inline_expand:"],
    Entry["active-search", "Active Search", "Search-as-you-type -- live_search:"],
    Entry["value-select", "Value Select", "Cascading selects -- one select repopulating another"],
    Entry["tabs", "Tabs", "Server-driven tab panes -- tabs:"],
    Entry["tooltip", "Tooltip", "Lazy-loaded hover detail -- tooltip:"],
    Entry["modal-dialog", "Modal Dialog", "Open a modal, close it, no JavaScript -- modal: + dismisses"],
    Entry["browser-dialogs", "Browser Dialogs", "Native confirm and prompt guards on actions"],
    Entry["keyboard-shortcuts", "Keyboard Shortcuts", "Key-driven actions via trigger:"],
    Entry["progress-bar", "Progress Bar", "A job-runner progress bar -- refreshes every:"],
    Entry["live-ticker", "Live Ticker", "Server-pushed updates over SSE -- pushes every:"],
    Entry["updating-other-content", "Updating Other Content",
          "One action updating several regions -- includes + triggers"]
  ].freeze

  private_constant :ENTRIES

  class << self
    def entries = ENTRIES

    def find(slug)
      ENTRIES.find { |entry| entry.slug == slug } || raise(Unknown, "No example with the slug #{slug.inspect}")
    end

    # The entries before and after this one, nil at either end: what a page's
    # previous and next links walk, which is the running examples only.
    def neighbors_of(slug, among: ENTRIES.select(&:live?))
      index = among.index { |entry| entry.slug == slug }
      [index.positive? ? among[index - 1] : nil, among[index + 1]]
    end

    # A page's slug comes from its own class name, so a page declares nothing but
    # its prose and its composition. It has to be a slug the catalog knows: a page
    # named for an example nobody listed would route at a URL nothing links to.
    def slug_for(page_class)
      find(page_class.name.delete_suffix("Page").underscore.tr("_", "-")).slug
    end
  end
end
