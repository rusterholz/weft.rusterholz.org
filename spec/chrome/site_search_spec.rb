# frozen_string_literal: true

require "nokogiri"

RSpec.describe SiteSearch do
  let(:search) { Nokogiri::HTML5.fragment(Weft::Context.new({}, nil, wire_params: {}) { site_search }.to_s) }

  it "asks for results as the visitor types: Active Search, running on the site itself" do
    input = search.at("input[type=search]")

    expect(input["name"]).to eq("q")
    expect(input["hx-get"]).to eq("/_components/search_results")
    expect(input["hx-trigger"]).to eq("input changed delay:300ms")
    expect(input["hx-target"]).to eq("#site-search-results")
  end

  it "fills a panel under the field" do
    expect(search.at("#site-search-results")).not_to be_nil
  end

  it "labels the field for someone who cannot see the magnifier" do
    expect(search.at("input[type=search]")["aria-label"]).to eq("Search the examples")
  end
end
