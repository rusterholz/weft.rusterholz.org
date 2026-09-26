# frozen_string_literal: true

require "active_support/core_ext/string/output_safety"
require "rouge"

# Shows a file, highlighted, as the code that produced whatever is above it.
# Reading it at render time is what keeps the code on the page the code that ran,
# and every example goes through here, so presentation is one place.
class CodeBlock < Weft::Component
  builder_method :code_block

  # A path inside this repository, all that is needed to find the file; the call
  # site names it where the reader sees it. Handed over, never on the wire, and the
  # <code> wrapper goes in as text: see docs/development.md, "Showing the Code".
  receives :path

  def build(attributes = {})
    super
    pre { text_node "<code>#{highlight}</code>".html_safe }
  end

  # Weft would give every block the one id its class name yields; a page shows several.
  def weft_dom_id = "code-#{params.path.gsub(/[^a-z0-9]+/i, '-')}"

  private

  def highlight
    self.class.formatter.format(self.class.lexer.lex(File.read(File.join(APP_ROOT, params.path))))
  end

  class << self
    def formatter = Rouge::Formatters::HTML.new

    def lexer = Rouge::Lexers::Ruby.new
  end
end
