# frozen_string_literal: true

require "nokogiri"

RSpec.describe SearchResults do
  def results(query) = Nokogiri::HTML5.fragment(described_class.render(q: query)).at("div")

  it "shows nothing until something is typed" do
    expect(results("").element_children).to be_empty
    expect(results("   ").element_children).to be_empty
  end

  it "links a running example, by title or by what it does, ignoring case" do
    expect(results("CLICK TO EDIT").css("a").map { |link| [link.at(".title").text, link["href"]] }).
      to eq([["Click to Edit", "/examples/click-to-edit"]])
    expect(results("transfers").at("a .title").text).to eq("Click to Edit")
  end

  it "names an example still to come, without linking it" do
    tabs = results("tabs").at("li")

    expect(tabs.at("a")).to be_nil
    expect(tabs.text).to include("Tabs")
    expect(tabs.text).to include("coming")
  end

  it "says so when nothing matches" do
    expect(results("sortable").at("p").text).to eq('No example matches "sortable".')
  end
end
