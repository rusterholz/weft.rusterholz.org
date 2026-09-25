# frozen_string_literal: true

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

  it "introduces the example in prose before the contact" do
    intro = page.at("#click-to-edit-contact-card-1").xpath("preceding-sibling::p")

    expect(intro.size).to eq(3)
    expect(intro.first.text).to start_with("A read-only view of a record with an Edit button.")
  end

  # Not a sample of the code: every file the example is made of, whole and
  # unaltered, one block each. Nothing here can drift from the classes that
  # rendered the card above it.
  it "shows each of the example's files exactly as it is on disk, in reading order" do
    shown = page.css("article pre").map(&:text)

    expect(shown).to eq(source_paths.map { |path| File.read(File.join(APP_ROOT, path)) })
    expect(page.css("article pre span[class]")).not_to be_empty
  end

  it "labels each block with the file it read" do
    labels = page.css("article pre").map { |pre| pre.previous_element.at("code").text.strip }

    expect(labels).to eq(source_paths)
  end

  it "links the source of the page and of every file the example is made of" do
    hrefs = page.css("h2:contains('Under the Hood') + ul a").map { |link| link["href"] }
    blob = "https://github.com/rusterholz/weft.rusterholz.org/blob/main/"

    expect(hrefs).to eq(["examples/v0.2/click_to_edit_page.rb", *source_paths].map { |path| blob + path })
  end

  # A path answers "where is it", not "which one do I want", so each link names
  # the class and says what it is for.
  it "names each piece of the example and says what it is" do
    names = page.css("h2:contains('Under the Hood') + ul a").map(&:text)

    expect(names).to eq(["This Page",
                         "Contacts -- where a visitor's contact is kept, standing in for your database",
                         "ContactCard -- the contact at rest, and the button that opens it for editing",
                         "ContactEditor -- the form in its editable expanded view"])
  end
end
