# frozen_string_literal: true

RSpec.describe SiteData::Misassembled do
  it "is the parent of every wiring error the site defines" do
    wiring_errors = [
      SiteData::Store::NoVisitor,
      SiteData::VisitorScope::NoSession,
      SiteData::Catalog::Unknown,
      SiteHelper::Undescribed,
      ExamplePage::Undescribed,
      ExamplePage::NoSuchExample,
      ExamplePage::NoWalkthrough
    ]

    expect(wiring_errors).to all(be < described_class)
  end

  it "is a StandardError, so weft's recovery sees it" do
    expect(described_class).to be < StandardError
  end
end
