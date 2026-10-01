# frozen_string_literal: true

require "securerandom"

# What SiteData::Records does is its own spec's; this is Updating Other Content's data.
RSpec.describe UpdatingOtherContent::ContactData do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  it "starts with Joe" do
    expect(described_class.all.map { |contact| [contact[:name], contact[:email]] }).to eq(
      [["Joe Smith", "joe@smith.org"]]
    )
  end

  it "keeps its contacts apart from Delete Row's" do
    described_class.create(name: "Angie MacDowell", email: "angie@macdowell.org")

    expect(DeleteRow::ContactData.all.size).to eq(3)
    expect(described_class.all.size).to eq(2)
  end
end
