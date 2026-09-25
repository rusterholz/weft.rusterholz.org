# frozen_string_literal: true

require "securerandom"

RSpec.describe ClickToEdit::Contacts do
  before { Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  it "finds a contact as it was seeded" do
    expect(described_class.find("1")).to eq(first_name: "Joe", last_name: "Blow", email: "joe@blow.com")
  end

  it "keeps an update" do
    described_class.update("1", first_name: "Joseph")

    expect(described_class.find("1")).to include(first_name: "Joseph", last_name: "Blow")
  end

  it "reads a missing attribute as unchanged, not blank" do
    described_class.update("1", first_name: nil, email: "joseph@blow.com")

    expect(described_class.find("1")).to include(first_name: "Joe", email: "joseph@blow.com")
  end

  it "ignores an attribute a contact does not have" do
    described_class.update("1", admin: true)

    expect(described_class.find("1").keys).to eq(%i[first_name last_name email])
  end

  it "answers a missing contact the same way whether reading or writing" do
    expect { described_class.find("2") }.to raise_error(Weft::NotFound, /"2"/)
    expect { described_class.update("2", first_name: "Joseph") }.to raise_error(Weft::NotFound, /"2"/)
  end
end
