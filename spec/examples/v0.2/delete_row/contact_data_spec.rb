# frozen_string_literal: true

require "securerandom"

# What SiteData::Records does is its own spec's; this is Delete Row's data.
RSpec.describe DeleteRow::ContactData do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  it "holds the three contacts as seeded, in order" do
    expect(described_class.all.map { |contact| [contact.id, contact[:name]] }).to eq(
      [["1", "Angie MacDowell"], ["2", "Fuqua Tarkenton"], ["3", "Kim Yee"]]
    )
    expect(described_class.find("3")[:status]).to eq("Inactive")
  end

  it "forgets a destroyed contact and keeps the rest in order" do
    described_class.find("2").destroy

    expect(described_class.all.map(&:id)).to eq(%w[1 3])
  end
end
