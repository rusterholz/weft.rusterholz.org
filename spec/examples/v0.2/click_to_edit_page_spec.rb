# frozen_string_literal: true

require "active_support/core_ext/string/filters"
require "nokogiri"
require "securerandom"

RSpec.describe ClickToEditPage do
  before { Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  let(:page) { Nokogiri::HTML5(described_class.render) }
  # In reading order: the data class, then the components.
  let(:source_paths) do
    %w[contacts contact_card contact_editor].map { |stem| "examples/v0.2/click_to_edit/#{stem}.rb" }
  end

  it "takes its heading and its title from the catalog" do
    expect(page.at("h1").text).to eq("Click to Edit")
    expect(page.at("title").text).to eq("Click to Edit · weft")
  end

  it "frames the walkthrough between the heading and the source" do
    expect(page.css("h2").map(&:text)).to eq(["How It Works", "Worth Noticing", "Under the Hood"])
  end

  it "embeds the visitor's own contact, live, ahead of the explanation" do
    ClickToEdit::Contacts.update("1", first_name: "Joseph")

    card = page.at("#click-to-edit-contact-card-1")

    expect(card.text).to include("Joseph")
    expect(card.at("button")).not_to be_nil
    expect(card.xpath("following::h2").first.text).to eq("How It Works")
  end

  it "warns about the log line, right after the contact it comes from" do
    callout = page.at("#click-to-edit-contact-card-1").next_element

    expect(callout["class"]).to eq("callout")
    expect(callout.text.squish).to eq(
      "If you run this example yourself, Weft logs a warning the first time you click Edit, Cancel or Save, " \
      "and on every click in development, where classes reload. It's harmless, and Weft plans to improve " \
      "how this case is handled."
    )
  end

  it "introduces the example in prose before the contact" do
    intro = page.at("#click-to-edit-contact-card-1").xpath("preceding-sibling::p")

    expect(intro.size).to eq(3)
    expect(intro.first.text).to start_with("A read-only view of a record with an Edit button.")
  end

  describe "under the hood" do
    let(:pieces) { page.css("h2:contains('Under the Hood') + ul > li.piece") }
    let(:blob) { "https://github.com/rusterholz/weft.rusterholz.org/blob/main/" }

    # A path answers "where is it", not "which one do I want", so each piece
    # names the class and says what it is for.
    it "lists the pieces of the example in reading order, each named and described" do
      expect(pieces.map { |piece| piece.at(".about").text }).to eq(
        ["Contacts -- where a visitor's contact is kept, standing in for your database",
         "ContactCard -- the contact at rest, and the button that opens it for editing",
         "ContactEditor -- the form in its editable expanded view"]
      )
    end

    # Not a sample of the code: every file the example is made of, whole and
    # unaltered, one per piece. Nothing here can drift from the classes that
    # rendered the card above it.
    it "holds each file exactly as it is on disk, highlighted" do
      shown = pieces.map { |piece| piece.at("details pre").text }

      expect(shown).to eq(source_paths.map { |path| File.read(File.join(APP_ROOT, path)) })
      expect(pieces.first.css("details pre span[class]")).not_to be_empty
    end

    it "keeps each file folded until asked, behind a summary naming it" do
      expect(pieces.map { |piece| piece.at("details")["open"] }).to all(be_nil)
      expect(pieces.map { |piece| piece.at("details > summary").text }).to eq(source_paths)
    end

    it "shows code nowhere else in the article" do
      expect(page.css("article pre").size).to eq(page.css("article details pre").size)
    end

    it "links each piece's file, and this page's" do
      this_page = page.at("h2:contains('Under the Hood') + ul > li:first-child a")

      expect(this_page.text).to eq("This Page")
      expect(this_page["href"]).to eq("#{blob}examples/v0.2/click_to_edit_page.rb")
      expect(pieces.map { |piece| piece.at("a")["href"] }).to eq(source_paths.map { |path| blob + path })
    end
  end

  it "gives no two elements the same id" do
    ids = page.css("[id]").map { |element| element["id"] }

    expect(ids.tally.select { |_id, count| count > 1 }).to be_empty
  end
end
