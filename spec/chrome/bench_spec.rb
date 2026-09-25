# frozen_string_literal: true

require "nokogiri"

RSpec.describe Bench do
  let(:path) { "examples/v0.2/click_to_edit_page.rb" }

  let(:bench) do
    html = Weft::Context.new({}, nil, wire_params: {}) { bench source_path: "examples/v0.2/click_to_edit_page.rb" }.to_s
    Nokogiri::HTML5.fragment(html).at("footer")
  end

  it "opens the hood on the page's own source" do
    link = bench.css("a").find { |a| a.text.start_with?("open the hood") }

    expect(link.text).to eq("open the hood: #{path}")
    expect(link["href"]).to eq("#{SITE_REPO_URL}/blob/main/#{path}")
  end

  it "names the weft it runs, linked to that release's changelog" do
    link = bench.css("a").find { |a| a.text.start_with?("weft ") }

    expect(link.text).to eq("weft #{Weft::VERSION}")
    expect(link["href"]).to eq("#{WEFT_REPO_URL}/blob/v#{Weft::VERSION}/CHANGELOG.md")
  end

  it "keeps a place for the last request, empty until one is made" do
    expect(bench.at(".bench-request").text).to be_empty
  end
end
