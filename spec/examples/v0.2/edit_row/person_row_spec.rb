# frozen_string_literal: true

require "json"
require "nokogiri"
require "securerandom"

RSpec.describe EditRow::PersonRow do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  # A row is parsed where a row can stand, or the parser drops its tags.
  let(:row) { Nokogiri::HTML5.fragment(described_class.render(person_id: "2"), context: "tbody").at("tr") }

  it "is a table row, one cell per field and one for its button" do
    expect(row.css("> td").map { |cell| cell.text.strip }).to eq(["Angie MacDowell", "angie@macdowell.org", "Edit"])
  end

  it "shows an edit the visitor has saved" do
    EditRow::PersonData.find("2").update(name: "Angie M.")

    expect(row.at("td").text).to eq("Angie M.")
  end

  it "takes its DOM id from the person it shows" do
    expect(row["id"]).to eq("edit-row-person-row-2")
  end

  it "hands its place to the editor with a GET, for the same person" do
    button = row.at("button")

    expect(button["hx-get"]).to eq("/_components/edit_row/person_row/edit")
    expect(JSON.parse(button["hx-vals"])).to eq("person_id" => "2")
    expect(button["hx-target"]).to eq("#edit-row-person-row-2")
    expect(button["hx-swap"]).to eq("outerHTML")
  end

  it "refuses a person the visitor does not have" do
    expect { described_class.render(person_id: "does-not-exist") }.to raise_error(Weft::NotFound)
  end
end
