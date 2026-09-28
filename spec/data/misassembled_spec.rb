# frozen_string_literal: true

RSpec.describe SiteData::Misassembled do
  # Error classes the site defines that are neither wiring errors nor weft's, each
  # with the reason it needs no recovers edge of its own. None yet.
  let(:allowed) { [] }

  def site_errors
    roots = [File.join(APP_ROOT, "app", ""), File.join(EXAMPLES_ROOT, "")]
    ObjectSpace.each_object(Class).select do |klass|
      path = klass < StandardError && klass.name && Object.const_source_location(klass.name)&.first
      path && roots.any? { |root| path.start_with?(root) }
    end
  end

  it "finds the error classes the site defines" do
    expect(site_errors).to include(SiteData::Store::NoVisitor, ExamplePage::NoWalkthrough)
  end

  it "is the parent of every error class the site defines, bar weft's own and the allowed" do
    stray = site_errors.reject { |klass| klass <= described_class || klass < Weft::Error || allowed.include?(klass) }

    expect(stray).to be_empty, "#{stray.map(&:name).join(', ')}: subclass SiteData::Misassembled, or allow it here"
  end

  it "is a StandardError, so weft's recovery sees it" do
    expect(described_class).to be < StandardError
  end
end
