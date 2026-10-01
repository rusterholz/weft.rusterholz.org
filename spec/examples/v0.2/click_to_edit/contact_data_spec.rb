# frozen_string_literal: true

require "securerandom"

# What SiteData::Records does is its own spec's; this is Click to Edit's data.
RSpec.describe ClickToEdit::ContactData do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  it "holds the one contact as seeded" do
    contact = described_class.find("1")

    expect(described_class.all.map(&:id)).to eq(%w[1])
    expect([contact[:first_name], contact[:last_name], contact[:email]]).to eq(%w[Joe Blow joe@blow.com])
  end

  it "keeps its contacts apart from every other example's" do
    described_class.find("1").update(first_name: "Joseph")

    expect(EditRow::PersonData.find("1")[:name]).to eq("Joe Smith")
    expect(described_class.find("1")[:first_name]).to eq("Joseph")
  end
end
