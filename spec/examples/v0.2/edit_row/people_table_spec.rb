# frozen_string_literal: true

require "nokogiri"
require "securerandom"

RSpec.describe EditRow::PeopleTable do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  let(:table) { Nokogiri::HTML5.fragment(described_class.render).at("table") }

  it "heads a column for each field, and one for the buttons" do
    expect(table.css("thead th").map(&:text)).to eq(["Name", "Email", ""])
  end

  it "renders a display row for each of the visitor's people, in order" do
    expect(table.css("tbody > tr").map { |row| row["id"] }).to eq(
      %w[edit-row-person-row-1 edit-row-person-row-2 edit-row-person-row-3]
    )
  end

  it "shows each person as the visitor's store has them" do
    EditRow::PersonData.find("3").update(name: "Fran Tarkenton")

    expect(table.css("tbody > tr > td:first-child").map(&:text)).to eq(
      ["Joe Smith", "Angie MacDowell", "Fran Tarkenton"]
    )
  end
end
