# frozen_string_literal: true

require "active_support/core_ext/string/output_safety"
require "rouge"

# Shows a file, highlighted, as the code that produced whatever is above it.
# Reading it at render time is what keeps the code on the page the code that ran,
# and every example goes through here, so presentation is one place.
class CodeBlock < Weft::Component
  builder_method :code_block

  # The path is a build argument and never a param, and the <code> wrapper goes
  # in as text rather than as a child tag. Both matter: see docs/development.md,
  # "Showing the Code".
  def build(path, attributes = {})
    super(attributes)
    pre { text_node "<code>#{CodeBlock.highlight(path)}</code>".html_safe }
  end

  class << self
    def highlight(path)
      formatter.format(lexer.lex(File.read(path)))
    end

    private

    def formatter = Rouge::Formatters::HTML.new

    def lexer = Rouge::Lexers::Ruby.new
  end
end
