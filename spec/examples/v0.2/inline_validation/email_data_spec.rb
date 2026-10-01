# frozen_string_literal: true

RSpec.describe InlineValidation::EmailData do
  it "knows the address already registered, and no other" do
    expect(described_class.taken?("taken@example.com")).to be(true)
    expect(described_class.taken?("maria@example.com")).to be(false)
  end
end
