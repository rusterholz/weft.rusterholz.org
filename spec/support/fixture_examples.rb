# frozen_string_literal: true

# Examples made in a spec, from spec/fixtures, and taken away again. Weft
# registers a component's route and Arbre defines its builder method on every
# element as the class is defined; forgetting undoes both, so nothing leaks into
# the specs that run after.
module FixtureExamples
  def load_fixture(file)
    before = Arbre::Element::BuilderMethods.instance_methods(false)
    load File.join(APP_ROOT, "spec", "fixtures", file)
    fixture_builders.concat(Arbre::Element::BuilderMethods.instance_methods(false) - before)
  end

  def forget_fixture(*classes)
    classes.each { |klass| Weft.registry.evict(klass) }
    fixture_builders.each { |name| Arbre::Element::BuilderMethods.remove_method(name) }
    fixture_builders.clear
  end

  private

  def fixture_builders = (@fixture_builders ||= [])
end
