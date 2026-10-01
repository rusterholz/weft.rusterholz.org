# frozen_string_literal: true

require "nokogiri"
require "securerandom"

RSpec.describe DeleteRowPage do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  let(:page) { Nokogiri::HTML5(described_class.render) }
  # In reading order: the data class, then the components.
  let(:source_paths) do
    %w[contact_data contact_book_table contact_row].map { |stem| "examples/v0.2/delete_row/#{stem}.rb" }
  end

  it "takes its heading and its title from the catalog" do
    expect(page.at("h1").text).to eq("Delete Row")
    expect(page.at("title").text).to eq("Delete Row · weft")
  end

  it "frames the walkthrough between the heading and the source" do
    expect(page.css("h2").map(&:text)).to eq(["How It Works", "Pieces You Need"])
  end

  # The path of one click first, then what to know before copying it.
  it "ends How It Works on the token a copied example needs" do
    paragraphs = page.xpath("//h2[.='How It Works']/following-sibling::*").take_while { |node| node.name == "p" }

    expect(paragraphs.first.text).to start_with("The row is the component.")
    expect(paragraphs.last.text).to start_with("This site sends every htmx request the visitor's CSRF token")
  end

  it "embeds the visitor's own contacts, live, in a frame of their own, ahead of the explanation" do
    DeleteRow::ContactData.find("2").destroy

    frame = page.at(".live-example")

    expect(frame.element_children.size).to eq(1)
    expect(frame.css("tbody > tr").map { |row| row.at("td").text }).to eq(["Angie MacDowell", "Kim Yee"])
    expect(frame.xpath("following::h2").first.text).to eq("How It Works")
  end

  it "introduces the example in prose before the table" do
    intro = page.at(".live-example").xpath("preceding-sibling::p")

    expect(intro.size).to eq(3)
    expect(intro.first.text).to start_with("A table of contacts, each row with a Delete button.")
  end

  it "says the token rides as a header, since a copied example needs the same" do
    expect(page.at("article").text).to include("sends every htmx request the visitor's CSRF token as a header")
  end

  it "names includes with the name it takes in weft 0.3" do
    expect(page.at("article").text).to include("In weft 0.3, includes becomes brings.")
  end

  describe "the pieces you need" do
    let(:pieces) { page.css("h2:contains('Pieces You Need') + ul > li.piece") }

    it "lists every piece in reading order, the page last, each named and described" do
      expect(pieces.map { |piece| piece.at(".about").text }).to eq(
        ["ContactData -- where a visitor's contacts are kept, standing in for your ORM model (SiteData::Records)",
         "ContactBookTable -- the table, handing each row the contact it shows",
         "ContactRow -- one contact, and the button that deletes it",
         "DeleteRowPage -- a page to put it on (yours needs only the contact_book_table call; " \
         "the rest is this walkthrough)"]
      )
    end

    it "holds each file exactly as it is on disk" do
      paths = [*source_paths, "examples/v0.2/delete_row_page.rb"]

      expect(pieces.map { |piece| piece.at("details pre").text }).to eq(
        paths.map { |path| File.read(File.join(APP_ROOT, path)) }
      )
    end

    it "lists no glue, since no form here needs the token field" do
      expect(page.css("h2:contains('Pieces You Need') + ul > li.glue")).to be_empty
    end
  end

  it "tints the table and its rows in the margin" do
    at_rest = page.css("aside.declarations .declaration.at-rest").map { |block| block["data-component"] }

    expect(at_rest).to eq(%w[DeleteRow::ContactBookTable DeleteRow::ContactRow])
  end

  it "walks back to Edit Row, the running example before it" do
    links = page.css("nav[aria-label='Pagination'] a").map { |link| [link.text, link["href"]] }

    expect(links.first).to eq(["← Previous: Edit Row", "/examples/edit-row"])
  end

  it "gives no two elements the same id" do
    ids = page.css("[id]").map { |element| element["id"] }

    expect(ids.tally.select { |_id, count| count > 1 }).to be_empty
  end
end
