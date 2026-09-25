# frozen_string_literal: true

require "nokogiri"

RSpec.describe Crumbs do
  def rendered(trail)
    html = Weft::Context.new({}, nil, wire_params: {}) { crumbs trail: trail }.to_s
    Nokogiri::HTML5.fragment(html)
  end

  let(:trail) { [["weft", "/"], ["UI Examples", "/"], ["Click to Edit", nil]] }

  it "links every step but the page you are on" do
    links = rendered(trail).css("nav a").map { |link| [link.text, link["href"]] }

    expect(links).to eq([["weft", "/"], ["UI Examples", "/"]])
  end

  it "names the page you are on without linking it" do
    here = rendered(trail).at("[aria-current='page']")

    expect(here.name).not_to eq("a")
    expect(here.text).to eq("Click to Edit")
  end

  it "leads with the wordmark" do
    expect(rendered(trail).at("nav a.wordmark").text).to eq("weft")
  end

  it "is a breadcrumb landmark" do
    expect(rendered(trail).at("nav")["aria-label"]).to eq("Breadcrumb")
  end
end
