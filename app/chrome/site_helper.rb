# frozen_string_literal: true

require "prism"

# The site's own components an example calls: the few small parts an adopter
# needs besides the example's classes. A helper extends this and describes
# itself once; which helpers an example uses is read from the example's files,
# as the declarations margin reads them, so the list follows the code.
module SiteHelper
  Undescribed = Class.new(StandardError)

  APP = File.join(APP_ROOT, "app", "")

  def describes(phrase) = @phrase = phrase

  def phrase = @phrase

  class << self
    # Each site component whose builder the files call, by name.
    def used_in(paths)
      called = paths.flat_map { |path| calls_in(path).map(&:name) }
      used = site_components.select { |klass| called.include?(builder_of(klass)) }.sort_by(&:name)
      used.each { |klass| described!(klass) }
    end

    def source_of(klass) = Object.const_source_location(klass.name)&.first

    private

    def site_components
      Weft.registry.components.select { |klass| klass.name && source_of(klass)&.start_with?(APP) }
    end

    def builder_of(klass)
      call = calls_in(source_of(klass)).find { |candidate| candidate.name == :builder_method }
      name = call.arguments&.arguments&.first if call
      name.unescaped.to_sym if name.is_a?(Prism::SymbolNode)
    end

    def described!(klass)
      return if klass.is_a?(SiteHelper) && klass.phrase

      raise Undescribed, "#{klass.name} is called by an example; extend SiteHelper and describe it"
    end

    # Receiverless calls only: a name in a string or a comment is not a use.
    def calls_in(path) = receiverless_calls(Prism.parse_file(path).value)

    def receiverless_calls(node)
      own = node.is_a?(Prism::CallNode) && node.receiver.nil? ? [node] : []
      own + node.compact_child_nodes.flat_map { |child| receiverless_calls(child) }
    end
  end
end
