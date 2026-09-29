# frozen_string_literal: true

require "securerandom"

RSpec.describe EditRow::PersonData do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  it "holds the three people as seeded, in order" do
    expect(described_class.all.keys).to eq(%w[1 2 3])
    expect(described_class.find("2")).to eq(name: "Angie MacDowell", email: "angie@macdowell.org")
  end

  it "keeps an update to one person and leaves the others alone" do
    described_class.update("2", name: "Angie M.", email: "angie@example.com")

    expect(described_class.find("2")).to eq(name: "Angie M.", email: "angie@example.com")
    expect(described_class.find("1")).to eq(name: "Joe Smith", email: "joe@smith.org")
  end

  it "goes back to the seed when reset" do
    described_class.update("1", name: "Joseph Smith")

    described_class.reset!

    expect(described_class.find("1")).to include(name: "Joe Smith")
  end

  it "reads a missing attribute as unchanged, not blank" do
    described_class.update("1", name: nil, email: "joseph@smith.org")

    expect(described_class.find("1")).to eq(name: "Joe Smith", email: "joseph@smith.org")
  end

  it "ignores an attribute a person does not have" do
    described_class.update("1", admin: true)

    expect(described_class.find("1").keys).to eq(%i[name email])
  end

  it "keeps one visitor's edit from the next" do
    described_class.update("1", name: "Joseph Smith")

    SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}"

    expect(described_class.find("1")).to include(name: "Joe Smith")
  end

  it "answers a missing person the same way whether reading or writing" do
    expect { described_class.find("4") }.to raise_error(Weft::NotFound, /"4"/)
    expect { described_class.update("4", name: "Nobody") }.to raise_error(Weft::NotFound, /"4"/)
  end
end
