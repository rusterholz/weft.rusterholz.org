# frozen_string_literal: true

require "nokogiri"

RSpec.describe ExamplesBar do
  let(:bar) do
    html = Weft::Context.new({}, nil, wire_params: {}) { examples_bar current: "click-to-edit" }.to_s
    Nokogiri::HTML5.fragment(html).at("nav")
  end

  it "lists every example in the catalog, in its order" do
    expect(bar.css(".entry").map { |entry| entry.text.delete_suffix(" (coming)") }).to eq(Catalog.entries.map(&:title))
  end

  it "marks the page you are on" do
    expect(bar.at("[aria-current='page']").text).to eq("Click to Edit")
  end

  it "links the examples that are running, and only those" do
    expect(bar.css("a").map { |link| link["href"] }).to eq(Catalog.entries.select(&:live?).map(&:path))
  end

  it "tells a screen reader which examples are still to come" do
    coming = bar.css(".entry.coming")

    expect(coming.size).to eq(Catalog.entries.count { |entry| !entry.live? })
    expect(coming.first.at(".visually-hidden").text).to eq(" (coming)")
  end

  it "is the UI Examples landmark" do
    expect(bar["aria-label"]).to eq("UI Examples")
  end
end
