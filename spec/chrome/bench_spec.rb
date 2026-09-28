# frozen_string_literal: true

require "nokogiri"

RSpec.describe Bench do
  let(:path) { "examples/v0.2/click_to_edit_page.rb" }

  let(:bench) do
    html = Weft::Context.new({}, nil, wire_params: {}) { bench source_path: "examples/v0.2/click_to_edit_page.rb" }.to_s
    Nokogiri::HTML5.fragment(html).at("footer")
  end

  it "opens the hood on the page's own source" do
    link = bench.css("a").find { |a| a.text.start_with?("Open the Hood") }

    expect(link.text).to eq("Open the Hood: #{path}")
    expect(link["href"]).to eq("#{SITE_REPO_URL}/blob/main/#{path}")
  end

  it "names the weft it runs, linked to that release's changelog" do
    link = bench.css("a").find { |a| a.text.start_with?("weft ") }

    expect(link.text).to eq("weft #{Weft::VERSION}")
    expect(link["href"]).to eq("#{WEFT_REPO_URL}/blob/v#{Weft::VERSION}/CHANGELOG.md")
  end

  # The site's script replaces the line with each request; without the script it never would, so it stays hidden.
  it "keeps a place for the last request, hidden until the site's script reveals it" do
    line = bench.at(".bench-request")

    expect(line.text).to eq("Your requests show here as you click.")
    expect(line).to have_attribute("hidden")
    expect(line).to have_attribute("data-reveal")
  end
end
