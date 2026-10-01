# frozen_string_literal: true

require "nokogiri"
require "securerandom"

RSpec.describe BulkUpdatePage do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  let(:page) { Nokogiri::HTML5(described_class.render) }
  let(:source_paths) { %w[member_data member_roster].map { |stem| "examples/v0.2/bulk_update/#{stem}.rb" } }

  it "takes its heading and its title from the catalog" do
    expect(page.at("h1").text).to eq("Bulk Update")
    expect(page.at("title").text).to eq("Bulk Update · weft")
  end

  it "frames one How It Works between the heading and the source" do
    expect(page.css("h2").map(&:text)).to eq(["How It Works", "Pieces You Need"])
  end

  it "embeds the visitor's own roster, live, in a frame of its own" do
    BulkUpdate::MemberData.find("4").update(active: true)

    frame = page.at(".live-example")

    expect(frame.element_children.map { |child| child["id"] }).to eq(["member-roster"])
    expect(frame.css("input[type=checkbox][checked]").size).to eq(4)
  end

  it "introduces the example in prose before the roster" do
    intro = page.at(".live-example").xpath("preceding-sibling::p")

    expect(intro.size).to eq(3)
    expect(intro.first.text).to start_with("A table of team members, each row with an Active checkbox.")
  end

  it "lists every piece in reading order, the page last, each named and described" do
    pieces = page.css("h2:contains('Pieces You Need') + ul > li.piece")

    expect(pieces.map { |piece| piece.at(".about").text }).to eq(
      ["MemberData -- where a visitor's members are kept, standing in for your database",
       "MemberRoster -- the whole roster as one form, its checkboxes and its status line",
       "BulkUpdatePage -- a page to put it on (yours needs only the member_roster call; " \
       "the rest is this walkthrough)"]
    )
    expect(pieces.map { |piece| piece.at("details pre").text }).to eq(
      [*source_paths, "examples/v0.2/bulk_update_page.rb"].map { |path| File.read(File.join(APP_ROOT, path)) }
    )
  end

  it "walks back to Delete Row, the running example before it" do
    links = page.css("nav[aria-label='Pagination'] a").map { |link| [link.text, link["href"]] }

    expect(links.first).to eq(["← Previous: Delete Row", "/examples/delete-row"])
  end

  it "gives no two elements the same id" do
    ids = page.css("[id]").map { |element| element["id"] }

    expect(ids.tally.select { |_id, count| count > 1 }).to be_empty
  end
end
