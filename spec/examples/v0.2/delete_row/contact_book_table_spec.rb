# frozen_string_literal: true

require "nokogiri"
require "securerandom"

RSpec.describe DeleteRow::ContactBookTable do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  let(:table) { Nokogiri::HTML5.fragment(described_class.render).at("table") }

  it "heads a column for each field, and one for the buttons" do
    expect(table.css("thead th").map(&:text)).to eq(["Name", "Email", "Status", ""])
  end

  it "renders a row for each of the visitor's contacts, in order" do
    expect(table.css("tbody > tr").map { |row| row["id"] }).to eq(
      %w[delete-row-contact-row-1 delete-row-contact-row-2 delete-row-contact-row-3]
    )
  end

  it "leaves out a contact the visitor has deleted" do
    DeleteRow::ContactData.delete("2")

    expect(table.css("tbody > tr > td:first-child").map(&:text)).to eq(["Angie MacDowell", "Kim Yee"])
  end
end
