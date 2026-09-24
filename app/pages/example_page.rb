# frozen_string_literal: true

# The frame every example page renders in: heading, the page's own walkthrough,
# the code that produced it, and links to the source of both. A concrete example
# page therefore declares nothing but its prose and its composition, taking its
# URL, heading and title from the catalog by way of its own class name.
class ExamplePage < ApplicationPage
  abstract!

  class << self
    def slug = Catalog.slug_for(self)

    def entry = Catalog.find(slug)

    # Overriding the derivation rather than declaring a value gives every
    # subclass its own, with nothing to remember to call.
    def title_declaration = "#{entry.title} · #{ApplicationPage::SITE_NAME}"

    private

    # Weft would derive "/click_to_edit"; the catalog owns these paths.
    def default_page_path = entry.path
  end

  def build(attributes = {})
    super
    h1 entry.title
    walkthrough
    example_source_paths.each { |path| code_block path }
    under_the_hood
  end

  # Without this, a page that forgot to write one would render nothing and say
  # nothing about it.
  def walkthrough
    raise NotImplementedError, "#{self.class} needs a walkthrough"
  end

  private

  def entry = self.class.entry

  # One file per class, found through the classes themselves rather than by
  # listing a directory, so the pages follow the code if the code ever moves.
  # Data first, then the components: the order someone reads them in.
  def example_source_paths
    classes = example_classes.sort_by { |klass| [klass < Weft::Component ? 1 : 0, klass.name] }
    classes.map { |klass| Object.const_source_location(klass.name).first }
  end

  def example_classes
    module_name = self.class.slug.tr("-", "_").camelize
    unless Object.const_defined?(module_name)
      raise Catalog::Unknown, "#{module_name} is not defined: is it under #{EXAMPLES_ROOT}?"
    end

    example = Object.const_get(module_name)
    example.constants(false).map { |name| example.const_get(name, false) }.grep(Class)
  end

  # `walkthrough` is the concrete page's own method, so this resolves to the file
  # the reader is looking at rather than to this one.
  def page_source_path = self.class.instance_method(:walkthrough).source_location.first

  def under_the_hood
    h2 "Under the Hood"
    ul do
      li { a "This page", href: source_url(page_source_path) }
      example_source_paths.each { |path| li { a relative_path(path), href: source_url(path) } }
    end
  end
end
