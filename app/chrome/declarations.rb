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
#
# Each block, and each action's declaration within it, carries the name the
# Weft-Site-Handled header gives when it answers (SiteData::HandledBy), so the
# page can light whatever handled the visitor's last request.
class Declarations < ApplicationComponent
  builder_method :declarations

  receives :components
  receives :at_rest
  receives :behind

  NOT_WEFT = %i[builder_method private protected public].freeze
  ACTIONS = %i[performs transfers dismisses].freeze
  BEHIND = { 1 => "Behind it", 2 => "Behind both" }.freeze

  def tag_name = "aside"

  def build(attributes = {})
    super(attributes.merge("aria-label": "Declarations"))
    add_class "declarations"
    span "Declarations", class: "heading"
    span "The one that answered your last click is lit.", class: "hint", hidden: true, "data-reveal": true
    params.components.each { |klass| block_for(klass) }
    behind
  end

  private

  def block_for(klass)
    div class: ["declaration", ("at-rest" if params.at_rest.include?(klass))].compact.join(" "),
        "data-component": klass.name do
      span klass.name.demodulize, class: "name"
      pre { text_node self.class.marked(klass) }
    end
  end

  def behind
    div(class: "behind") { text_node behind_sentence }
  end

  # As one text node: Arbre indents a nested tag, and inside a sentence the indent shows.
  def behind_sentence
    notes = params.behind.map do |klass, phrase|
      "<code>#{ERB::Util.html_escape(klass.name.demodulize)}</code>, #{ERB::Util.html_escape(phrase)}."
    end
    "#{BEHIND.fetch(params.components.size, 'Behind them all')}: #{notes.join(' ')}".html_safe
  end

  class << self
    # The declarations as the file writes them, one per line, keeping the blank
    # lines between groups; each action's in a span naming what answers when it
    # runs, "ClickToEdit::ContactCard#edit".
    def marked(klass)
      statements = statements_of(klass)
      statements.each_with_index.map do |node, index|
        gap = index.positive? && node.location.start_line > statements[index - 1].location.end_line + 1
        "#{"\n" if gap}#{markup(klass, node)}"
      end.join("\n").html_safe
    end

    private

    def markup(klass, node)
      text = ERB::Util.html_escape(dedented(node))
      handles = handles(klass, node)
      handles ? %(<span data-handles="#{ERB::Util.html_escape(handles)}">#{text}</span>) : text
    end

    def statements_of(klass)
      path, = Object.const_source_location(klass.name)
      declarations_in(class_node(Prism.parse_file(path).value, klass.name.demodulize))
    end

    # A nameless action answers at the component's own path, so it is named as the component is.
    def handles(klass, node)
      return unless ACTIONS.include?(node.name)

      name = node.arguments&.arguments&.first
      name.is_a?(Prism::SymbolNode) ? "#{klass.name}##{name.unescaped}" : klass.name
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
