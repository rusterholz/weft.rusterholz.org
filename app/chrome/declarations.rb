# frozen_string_literal: true

require "active_support/core_ext/string/output_safety"
require "erb"
require "prism"

# The margin beside an example: each component's class-body declarations, the
# anatomy of the example, closed by a note on the data class they stand on.
#
# The declarations are the file's own text, parsed out of it, so the margin can
# show nothing the running class does not say. A declaration is any bare call in
# the class body except the few that are Ruby's or Arbre's rather than weft's.
# The components on the page at rest are the tinted ones.
class Declarations < Weft::Component
  builder_method :declarations

  receives :components
  receives :at_rest
  receives :behind
  receives :slug

  NOT_WEFT = %i[builder_method private protected public].freeze
  BEHIND = { 1 => "Behind it", 2 => "Behind both" }.freeze

  def tag_name = "aside"

  def build(attributes = {})
    super(attributes.merge(class: "declarations", "aria-label": "Declarations"))
    span "Declarations", class: "heading"
    params.components.each { |klass| block_for(klass) }
    behind
  end

  private

  def block_for(klass)
    div class: ["declaration", ("at-rest" if params.at_rest.include?(klass))].compact.join(" ") do
      span klass.name.demodulize, class: "name"
      pre { text_node lines_of(klass) }
    end
  end

  # A line to a span, so a long one wraps under a hanging indent rather than
  # back to the margin's edge. As one text node, since Arbre would indent the spans.
  def lines_of(klass)
    self.class.of(klass).lines(chomp: true).map do |line|
      "<span class=\"line\">#{ERB::Util.html_escape(line)}</span>"
    end.join.html_safe
  end

  def behind
    div class: "behind" do
      para { text_node behind_sentence }
      reset_example slug: params.slug
    end
  end

  # As one text node: Arbre indents a nested tag, and inside a sentence the indent shows.
  def behind_sentence
    notes = params.behind.map do |klass, phrase|
      "<code>#{ERB::Util.html_escape(klass.name.demodulize)}</code>, #{ERB::Util.html_escape(phrase)}."
    end
    "#{BEHIND.fetch(params.components.size, 'Behind them all')}: #{notes.join(' ')}".html_safe
  end

  class << self
    def of(klass)
      path, = Object.const_source_location(klass.name)
      laid_out(declarations_in(class_node(Prism.parse_file(path).value, klass.name.demodulize)))
    end

    private

    # One per line, keeping the blank lines the file puts between groups.
    def laid_out(statements)
      statements.each_with_index.map do |node, index|
        gap = index.positive? && node.location.start_line > statements[index - 1].location.end_line + 1
        "#{"\n" if gap}#{dedented(node)}"
      end.join("\n")
    end

    def class_node(node, name)
      return node if node.is_a?(Prism::ClassNode) && node.constant_path.slice == name

      node.compact_child_nodes.lazy.filter_map { |child| class_node(child, name) }.first
    end

    def declarations_in(klass_node)
      Array(klass_node.body&.body).select do |node|
        node.is_a?(Prism::CallNode) && node.receiver.nil? && !NOT_WEFT.include?(node.name)
      end
    end

    # A block's later lines keep the file's indentation; the first line's is gone.
    def dedented(node)
      indent = node.location.start_column
      node.slice.gsub(/\n {#{indent}}/, "\n")
    end
  end
end
