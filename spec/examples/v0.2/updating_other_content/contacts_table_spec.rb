# frozen_string_literal: true

require "nokogiri"
require "securerandom"

RSpec.describe UpdatingOtherContent::ContactsTable do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  let(:wrapper) { Nokogiri::HTML5.fragment(described_class.render).at("div") }

  # Its id is where the form's response sends the table.
  it "takes the DOM id an out-of-band swap is addressed to" do
    expect(wrapper["id"]).to eq("updating-other-content-contacts-table")
  end

  it "shows each of the visitor's contacts, in order" do
    UpdatingOtherContent::ContactData.create(name: "Angie MacDowell", email: "angie@macdowell.org")

    expect(wrapper.css("thead th").map(&:text)).to eq(%w[Name Email])
    expect(wrapper.css("tbody > tr").map { |row| row.css("td").map(&:text) }).to eq(
      [["Joe Smith", "joe@smith.org"], ["Angie MacDowell", "angie@macdowell.org"]]
    )
  end

  it "carries no wiring of its own" do
    expect(wrapper.to_h.keys.grep(/\Ahx-/)).to be_empty
  end
end
