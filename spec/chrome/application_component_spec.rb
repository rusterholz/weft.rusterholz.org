# frozen_string_literal: true

RSpec.describe ApplicationComponent do
  def site_components
    Weft.registry.components.select { |klass| SiteHelper.source_of(klass)&.start_with?(SiteHelper::APP) }
  end

  it "is the base of every component the site defines for itself" do
    expect(site_components - [described_class]).to all(be < described_class)
  end

  it "leaves the examples' components on Weft::Component, as weft's docs write them" do
    expect(ClickToEdit::ContactCard.superclass).to eq(Weft::Component)
    expect(ClickToEdit::ContactEditor.superclass).to eq(Weft::Component)
  end

  it "serves nothing on its own" do
    expect(described_class).not_to be_routable
  end

  # Weft's own StandardError edge renders the same fragment with the same status;
  # what this edge adds is a declaration a search for a wiring error ends at.
  it "recovers from the site's wiring errors in place, on an edge of its own" do
    [described_class, ResetExample, VersionPicker].each do |component|
      edge = component.recovery_for(ExamplePage::NoSuchExample.new)

      expect(edge).to include(from: SiteData::Misassembled, with: :error_component, status: 500)
    end
  end
end
