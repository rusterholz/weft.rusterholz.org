# frozen_string_literal: true

# A fixture example's classes leave the process as they came: out of weft's
# route table, and with no builder method left on every Arbre element.
RSpec.describe "a fixture example, once forgotten" do
  before do
    stub_const("Tabs", Module.new)
    stub_const("TabsPage", Class.new(ExamplePage))
    load_fixture "tabs_example.rb"
    forget_fixture(TabsPage, Tabs::TabStrip)
  end

  it "leaves no builder method behind" do
    expect(Arbre::Element::BuilderMethods.method_defined?(:spec_tab_strip)).to be(false)
  end

  it "leaves nothing in weft's registry" do
    expect(Weft.registry.components.map(&:name)).not_to include("Tabs::TabStrip")
  end
end
