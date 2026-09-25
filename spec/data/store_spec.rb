# frozen_string_literal: true

RSpec.describe Store do
  let(:seed) { { "1" => { "name" => "Joe" } }.freeze }

  # One cache serves the whole process, so examples that shared a visitor would
  # inherit each other's writes -- and a first read is a different code path
  # from every read after it, which is the one worth arriving at clean.
  before { Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  def slice(example = "widgets") = described_class.for(example, seed: seed)

  it "hands out one example's slice" do
    expect(slice).to be_a(Store::ExampleSlice)
  end

  it "hands out the seed until something is written" do
    expect(slice.fetch).to eq("1" => { "name" => "Joe" })
  end

  it "keeps what a visitor writes" do
    slice.update { |widgets| widgets["1"]["name"] = "Joseph" }

    expect(slice.fetch).to eq("1" => { "name" => "Joseph" })
  end

  it "seeds from a copy, so the seed itself cannot be edited" do
    slice.update { |widgets| widgets["1"]["name"] = "Joseph" }

    expect(seed).to eq("1" => { "name" => "Joe" })
  end

  it "gives each visitor their own copy" do
    slice.update { |widgets| widgets["1"]["name"] = "Joseph" }

    Current.visitor = "a-different-visitor"

    expect(slice.fetch).to eq("1" => { "name" => "Joe" })
  end

  it "keeps one example's slice out of another's way" do
    slice("widgets").update { |widgets| widgets["1"]["name"] = "Joseph" }

    expect(slice("gadgets").fetch).to eq("1" => { "name" => "Joe" })
  end

  it "puts the seed back when a slice is reset" do
    slice.update { |widgets| widgets["1"]["name"] = "Joseph" }

    slice.reset!

    expect(slice.fetch).to eq("1" => { "name" => "Joe" })
  end

  it "forgets a visitor's data once its time is up" do
    slice.update { |widgets| widgets["1"]["name"] = "Joseph" }

    travel(Store::TTL + 60) do
      expect(slice.fetch).to eq("1" => { "name" => "Joe" })
    end
  end

  it "says what is wrong when there is no visitor to scope to" do
    Current.reset

    expect { slice }.to raise_error(Store::NoVisitor, /VisitorScope/)
  end
end
