# frozen_string_literal: true

require "nokogiri"

RSpec.describe HomePage do
  let(:page) { Nokogiri::HTML5(described_class.render) }
  let(:index) { page.css("main ol.index > li") }

  it "is the UI Examples index, and says so in the crumb and the heading alike" do
    expect(page.at("main h1").text).to eq("UI Examples")
    expect(page.at("header [aria-current='page']").text).to eq("UI Examples")
  end

  it "opens with the pitch, before the index" do
    pitch = page.css("main h1 ~ p")

    expect(pitch.size).to eq(3)
    expect(pitch.first.text).
      to eq("Every example that ships with Weft, running live, beside the code that rendered it.")
  end

  it "lists every example in the catalog, in its order, with what it shows" do
    expect(index.map { |item| item.at(".title").text }).to eq(Catalog.entries.map(&:title))
    expect(index.first.at(".summary").text).to eq(Catalog.entries.first.summary)
  end

  it "links the running examples and marks the rest as coming" do
    running, coming = index.partition { |item| item.at("a") }

    expect(running.map { |item| item.at("a")["href"] }).to eq(Catalog.entries.select(&:live?).map(&:path))
    expect(coming).to all(satisfy { |item| item.at(".coming").text == "coming" })
  end
end
