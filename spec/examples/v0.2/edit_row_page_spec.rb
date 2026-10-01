# frozen_string_literal: true

require "active_support/core_ext/string/filters"
require "nokogiri"
require "securerandom"

RSpec.describe EditRowPage do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  let(:page) { Nokogiri::HTML5(described_class.render) }
  # In reading order: the data class, then the components.
  let(:source_paths) do
    %w[person_data people_table person_row person_row_editor].map { |stem| "examples/v0.2/edit_row/#{stem}.rb" }
  end

  it "takes its heading and its title from the catalog" do
    expect(page.at("h1").text).to eq("Edit Row")
    expect(page.at("title").text).to eq("Edit Row · weft")
  end

  it "frames the walkthrough between the heading and the source" do
    expect(page.css("h2").map(&:text)).to eq(["How It Works", "Pieces You Need"])
  end

  it "walks How It Works from the table's first render to what one row's edit leaves alone" do
    paragraphs = page.xpath("//h2[.='How It Works']/following-sibling::*").take_while { |node| node.name == "p" }

    expect(paragraphs.first.text).to start_with("Each row is a component that renders as a table row.")
    expect(paragraphs.last.text).to start_with("Rows edit independently.")
  end

  it "embeds the visitor's own people, live, in a frame of their own, ahead of the explanation" do
    EditRow::PersonData.find("2").update(name: "Angie M.")

    frame = page.at(".live-example")

    expect(frame.element_children.map(&:name)).to eq(["div"])
    expect(frame.css("tbody > tr").map { |row| row.at("td").text }).to eq(["Joe Smith", "Angie M.", "Fuqua Tarkenton"])
    expect(frame.xpath("following::h2").first.text).to eq("How It Works")
  end

  it "warns about the log line, right after the live table, outside its frame" do
    callout = page.at(".live-example").next_element

    expect(callout["class"]).to eq("callout")
    expect(callout.text.squish).to eq(
      "If you run this example yourself, Weft logs a warning the first time you click Edit, Cancel or Save, " \
      "and on every click in development, where classes reload. It's harmless, and Weft plans to improve " \
      "how this case is handled."
    )
  end

  it "introduces the example in prose before the table" do
    intro = page.at(".live-example").xpath("preceding-sibling::p")

    expect(intro.size).to eq(3)
    expect(intro.first.text).to start_with("A table where each row can switch into an editable state.")
  end

  describe "the pieces you need" do
    let(:pieces) { page.css("h2:contains('Pieces You Need') + ul > li.piece") }

    it "lists every piece in reading order, the page last, each named and described" do
      expect(pieces.map { |piece| piece.at(".about").text }).to eq(
        ["PersonData -- where a visitor's people are kept, standing in for your ORM model (SiteData::Records)",
         "PeopleTable -- the table, handing each row the person it shows",
         "PersonRow -- one person at rest, and the button that opens the row for editing",
         "PersonRowEditor -- the row in its editable state, its fields tied to a form in the last cell",
         "EditRowPage -- a page to put it on (yours needs only the people_table call; " \
         "the rest is this walkthrough)"]
      )
    end

    it "holds each file exactly as it is on disk" do
      paths = [*source_paths, "examples/v0.2/edit_row_page.rb"]

      expect(pieces.map { |piece| piece.at("details pre").text }).to eq(
        paths.map { |path| File.read(File.join(APP_ROOT, path)) }
      )
    end

    it "lists the CSRF field the editor's form calls as glue" do
      glue = page.css("h2:contains('Pieces You Need') + ul > li.glue li.piece .about").map(&:text)

      expect(glue).to eq(["AuthenticityTokenField -- the hidden field that carries the visitor's CSRF token, " \
                          "in every form that writes"])
    end
  end

  it "tints the table and its rows in the margin, the components on the page before anyone clicks" do
    at_rest = page.css("aside.declarations .declaration.at-rest").map { |block| block["data-component"] }

    expect(at_rest).to eq(%w[EditRow::PeopleTable EditRow::PersonRow])
  end

  it "walks back to Click to Edit, the running example before it" do
    links = page.css("nav[aria-label='Pagination'] a").map { |link| [link.text, link["href"]] }

    expect(links.first).to eq(["← Previous: Click to Edit", "/examples/click-to-edit"])
  end

  it "gives no two elements the same id" do
    ids = page.css("[id]").map { |element| element["id"] }

    expect(ids.tally.select { |_id, count| count > 1 }).to be_empty
  end
end
