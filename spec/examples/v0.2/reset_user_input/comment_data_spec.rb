# frozen_string_literal: true

require "securerandom"

# What SiteData::Records does is its own spec's; this is Reset User Input's data.
RSpec.describe ResetUserInput::CommentData do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  it "starts with Rosa's comment" do
    expect(described_class.all.map { |comment| [comment[:author], comment[:body]] }).to eq(
      [["Rosa", "Lovely event, and count me in for next year."]]
    )
  end

  it "adds a comment after the rest" do
    described_class.create(author: "Elena", body: "See you there!")

    expect(described_class.all.map { |comment| comment[:author] }).to eq(%w[Rosa Elena])
  end
end
