# frozen_string_literal: true

require "active_support/core_ext/string/output_safety"
require "rouge"

# Shows a file, highlighted, as the code that produced whatever is above it.
# Reading it at render time is what keeps the code on the page the code that ran,
# and every example goes through here, so presentation is one place.
class CodeBlock < Weft::Component
  builder_method :code_block

  # Takes a path inside this repository, which is both the label and all that is
  # needed to find the file. Never a declared param, and the <code> wrapper goes
  # in as text: see docs/development.md, "Showing the Code".
  def build(path, attributes = {})
    super(attributes)
    para { code path }
    pre { text_node "<code>#{CodeBlock.highlight(path)}</code>".html_safe }
  end

  class << self
    def highlight(path)
      formatter.format(lexer.lex(File.read(File.join(APP_ROOT, path))))
    end

    private

    def formatter = Rouge::Formatters::HTML.new

    def lexer = Rouge::Lexers::Ruby.new
  end
end
