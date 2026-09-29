# frozen_string_literal: true

require "securerandom"

# What SiteData::Records does is its own spec's; this is Edit Row's data.
RSpec.describe EditRow::PersonData do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  it "holds the three people as seeded, in order" do
    expect(described_class.all.map { |person| [person.id, person[:name]] }).to eq(
      [["1", "Joe Smith"], ["2", "Angie MacDowell"], ["3", "Fuqua Tarkenton"]]
    )
    expect(described_class.find("2")[:email]).to eq("angie@macdowell.org")
  end

  it "keeps an update to one person and leaves the others alone" do
    described_class.find("2").update(name: "Angie M.")

    expect(described_class.all.map { |person| person[:name] }).to eq(["Joe Smith", "Angie M.", "Fuqua Tarkenton"])
  end
end
