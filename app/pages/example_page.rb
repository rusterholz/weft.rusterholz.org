# frozen_string_literal: true

require "active_support/core_ext/module/delegation"
require "active_support/core_ext/string/inflections"

# The frame every example page renders in: the list of examples down the left,
# the article (heading, the page's own walkthrough, the code that produced it,
# links to the source of both) and the declarations margin on the right. A
# concrete example page therefore declares nothing but its prose and its
# composition, taking its URL, heading and title from the catalog by way of its
# own class name.
class ExamplePage < ApplicationPage
  abstract!

  Undescribed = Class.new(StandardError)
  NoSuchExample = Class.new(StandardError)

  delegate :entry, to: :class, private: true

  def build(attributes = {})
    super
    @content.remove_class("single-column")
    @content.add_class("example-layout")
    examples_bar current: entry.slug
    shown = article { article_body }
    declarations components: components, at_rest: components_in(shown), behind: data_classes
  end

  # Without this, a page that forgot to write one would render nothing and say
  # nothing about it.
  def walkthrough
    raise NotImplementedError, "#{self.class} needs a walkthrough"
  end

  private

  # Frames what a walkthrough renders live, setting it apart from the prose;
  # whatever the live component swaps in lands inside.
  def live(&) = div(class: "live-example", &)

  def article_body
    h1 entry.title
    reset_example slug: entry.slug
    walkthrough
    under_the_hood
    pagination
  end

  def trail = [[SITE_NAME, "/"], ["UI Examples", "/"], [entry.title, nil]]

  def components = self.class.example_classes.select { |klass| klass < Weft::Component }

  def data_classes = (self.class.example_classes - components).to_h { |klass| [klass, self.class.phrase_for(klass)] }

  # The example's components as the article renders them before anyone clicks.
  def components_in(element)
    element.children.flat_map do |child|
      [(child.class if components.include?(child.class)), *components_in(child)].compact
    end.uniq
  end

  # Found through the classes themselves rather than by listing a directory, so
  # the blocks and the links follow the code if the code ever moves.
  def example_sources
    @example_sources ||= self.class.example_classes.
                         to_h { |klass| [klass, repo_path(Object.const_source_location(klass.name).first)] }
  end

  # `walkthrough` is the concrete page's own method, so this resolves to the file
  # the reader is looking at rather than to this one.
  def page_source_path = repo_path(self.class.instance_method(:walkthrough).source_location.first)

  # The pieces you need, in reading order: each named and described, its whole
  # file folded away under its path, and the file on GitHub.
  def under_the_hood
    h2 "Under the Hood"
    ul class: "pieces" do
      li { a "This Page", href: source_url(page_source_path) }
      example_sources.each { |klass, path| li(class: "piece") { piece(klass, path) } }
    end
  end

  def piece(klass, path)
    para "#{klass.name.demodulize} -- #{self.class.phrase_for(klass)}", class: "about"
    details do
      summary path
      code_block path: path
    end
    a "View on GitHub", href: source_url(path)
  end

  # Previous and next walk the running examples; the way back to all of them is always there.
  def pagination
    previous, following = Catalog.neighbors_of(entry.slug)
    nav "aria-label": "Pagination", class: "pagination" do
      a "← #{previous ? "Previous: #{previous.title}" : 'All UI Examples'}", href: previous&.path || "/"
      a "Next: #{following.title} →", href: following.path if following
    end
  end

  class << self
    # Every data class of a running example back to its seed, for this visitor;
    # answers the page's path. A slug that is not a running example is not found.
    def reset!(slug)
      entry = Catalog.entries.find { |candidate| candidate.slug == slug && candidate.live? }
      raise Weft::NotFound, "No running example #{slug.inspect}" unless entry

      Object.const_get(entry.page_name).example_classes.select { |klass| klass.respond_to?(:reset!) }.each(&:reset!)
      entry.path
    end

    def slug = Catalog.slug_for(self)

    def entry = Catalog.find(slug)

    # Each example's browser title comes from its catalog entry, so no example
    # page declares a `title` of its own.
    def title_declaration = "#{entry.title} · #{ApplicationPage::SITE_NAME}"

    # Each of the example's classes in a phrase, so "which piece do I want?" is
    # answerable from the list. On the page, since the example's files are the code.
    def describes(**phrases) = @phrases = phrases

    def described_keys = (@phrases || {}).keys

    def phrase_for(klass)
      (@phrases || {}).fetch(key_for(klass)) { raise Undescribed, "#{name} describes no #{klass.name}" }
    end

    def key_for(klass) = klass.name.demodulize.underscore.to_sym

    # Data first, then the components by name, which is the order someone reads
    # them in. Module#constants makes no promises, so the order is made here.
    def in_reading_order(classes)
      classes.sort_by { |klass| [klass < Weft::Component ? 1 : 0, klass.name] }
    end

    def example_classes
      module_name = slug.tr("-", "_").camelize
      raise NoSuchExample, "#{module_name} is not defined: is it under #{EXAMPLES_ROOT}?" unless
        Object.const_defined?(module_name)

      example = Object.const_get(module_name)
      in_reading_order(example.constants(false).map { |name| example.const_get(name, false) })
    end

    private

    # Weft would derive "/click_to_edit"; the catalog owns these paths.
    def default_page_path = entry.path
  end
end
