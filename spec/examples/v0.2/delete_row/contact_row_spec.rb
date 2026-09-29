# frozen_string_literal: true

require "json"
require "nokogiri"
require "securerandom"

RSpec.describe DeleteRow::ContactRow do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  # A row is parsed where a row can stand, or the parser drops its tags.
  let(:row) { Nokogiri::HTML5.fragment(described_class.render(contact_id: "1"), context: "tbody").at("tr") }
  let(:button) { row.at("button") }

  it "is a table row, one cell per field and one for its button" do
    expect(row.css("> td").map { |cell| cell.text.strip }).to eq(
      ["Angie MacDowell", "angie@macdowell.org", "Active", "Delete"]
    )
  end

  it "takes its DOM id from the contact it shows" do
    expect(row["id"]).to eq("delete-row-contact-row-1")
  end

  it "deletes with a DELETE for the same contact, and removes itself when it succeeds" do
    expect(button["hx-delete"]).to eq("/_components/delete_row/contact_row/destroy")
    expect(JSON.parse(button["hx-vals"])).to eq("contact_id" => "1")
    expect(button["hx-target"]).to eq("#delete-row-contact-row-1")
    expect(button["hx-swap"]).to eq("delete")
  end

  it "asks the browser to confirm before it sends anything" do
    expect(button["hx-confirm"]).to eq("Are you sure?")
  end

  it "refuses a contact the visitor does not have" do
    DeleteRow::ContactData.delete("1")

    expect { described_class.render(contact_id: "1") }.to raise_error(Weft::NotFound)
  end
end
