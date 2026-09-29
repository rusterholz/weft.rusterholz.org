# frozen_string_literal: true

require "securerandom"

RSpec.describe DeleteRow::ContactData do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  it "holds the three contacts as seeded, in order" do
    expect(described_class.all.keys).to eq(%w[1 2 3])
    expect(described_class.find("3")).to eq(name: "Kim Yee", email: "kim@yee.org", status: "Inactive")
  end

  it "forgets a deleted contact and keeps the rest in order" do
    described_class.delete("2")

    expect(described_class.all.keys).to eq(%w[1 3])
  end

  it "goes back to the seed when reset" do
    described_class.delete("2")

    described_class.reset!

    expect(described_class.all.keys).to eq(%w[1 2 3])
  end

  it "keeps one visitor's delete from the next" do
    described_class.delete("2")

    SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}"

    expect(described_class.all.keys).to eq(%w[1 2 3])
  end

  it "answers a missing contact the same way whether reading or deleting" do
    described_class.delete("2")

    expect { described_class.find("2") }.to raise_error(Weft::NotFound, /"2"/)
    expect { described_class.delete("2") }.to raise_error(Weft::NotFound, /"2"/)
  end
end
