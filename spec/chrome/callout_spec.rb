# frozen_string_literal: true

require "nokogiri"

RSpec.describe Callout do
  def rendered(&) = Nokogiri::HTML5.fragment(Weft::Context.new({}, nil, wire_params: {}, &).to_s)

  it "holds whatever the page writes in it, marked as a note" do
    callout = rendered { callout { para "Worth knowing." } }.at(".callout")

    expect(callout["role"]).to eq("note")
    expect(callout.at("p").text).to eq("Worth knowing.")
  end

  it "can appear more than once on a page without repeating an id" do
    two = rendered do
      callout { para "One." }
      callout { para "Two." }
    end
    ids = two.css("[id]").map { |element| element["id"] }

    expect(ids.uniq).to eq(ids)
  end
end
