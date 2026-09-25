# frozen_string_literal: true

require "active_support/core_ext/module/delegation"
require "active_support/core_ext/string/inflections"

# The frame every example page renders in: heading, the page's own walkthrough,
# the code that produced it, and links to the source of both. A concrete example
# page therefore declares nothing but its prose and its composition, taking its
# URL, heading and title from the catalog by way of its own class name.
class ExamplePage < ApplicationPage
  abstract!

  Undescribed = Class.new(StandardError)
  NoSuchExample = Class.new(StandardError)

  delegate :entry, to: :class, private: true

  def build(attributes = {})
    super
    h1 entry.title
    walkthrough
    example_sources.each_value { |path| code_block path: path }
    under_the_hood
  end

  # Without this, a page that forgot to write one would render nothing and say
  # nothing about it.
  def walkthrough
    raise NotImplementedError, "#{self.class} needs a walkthrough"
  end

  class << self
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

  private

  # Found through the classes themselves rather than by listing a directory, so
  # the blocks and the links follow the code if the code ever moves.
  def example_sources
    @example_sources ||= self.class.example_classes.
                         to_h { |klass| [klass, repo_path(Object.const_source_location(klass.name).first)] }
  end

  # `walkthrough` is the concrete page's own method, so this resolves to the file
  # the reader is looking at rather than to this one.
  def page_source_path = repo_path(self.class.instance_method(:walkthrough).source_location.first)

  def under_the_hood
    h2 "Under the Hood"
    ul do
      li { a "This Page", href: source_url(page_source_path) }
      example_sources.each do |klass, path|
        li { a "#{klass.name.demodulize} -- #{self.class.phrase_for(klass)}", href: source_url(path) }
      end
    end
  end
end
