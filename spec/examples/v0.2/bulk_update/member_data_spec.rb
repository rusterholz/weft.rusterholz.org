# frozen_string_literal: true

require "securerandom"

# What SiteData::Records does is its own spec's; this is Bulk Update's data.
RSpec.describe BulkUpdate::MemberData do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  it "holds the four members as seeded, three active and Kim not" do
    expect(described_class.all.map { |member| [member.id, member[:name], member[:active]] }).to eq(
      [["1", "Joe Smith", true], ["2", "Angie MacDowell", true],
       ["3", "Fuqua Tarkenton", true], ["4", "Kim Yee", false]]
    )
  end

  # false is a value, not a left-out field.
  it "keeps a member switched off" do
    described_class.find("1").update(active: false)

    expect(described_class.find("1")[:active]).to be(false)
  end
end
