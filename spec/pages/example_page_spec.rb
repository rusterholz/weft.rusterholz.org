# frozen_string_literal: true

require "nokogiri"
require "securerandom"

RSpec.describe ExamplePage do
  describe "the three columns, on a live example" do
    before { Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

    let(:page) { Nokogiri::HTML5(ClickToEditPage.render) }

    it "sets the example list, the article and the declarations side by side" do
      expect(page.at("main").element_children.map(&:name)).to eq(%w[nav article aside])
      expect(page.at("main > article > h1").text).to eq("Click to Edit")
    end

    it "says where you are: weft, then UI Examples, then the example" do
      crumbs = page.at("header nav[aria-label='Breadcrumb']")

      expect(crumbs.css("a, [aria-current]").map(&:text)).to eq(["weft", "UI Examples", "Click to Edit"])
    end

    it "lists the declarations of every component the example is made of" do
      expect(page.css("aside .declaration .name").map(&:text)).to eq(%w[ContactCard ContactEditor])
    end

    it "tints the components the article shows at rest" do
      expect(page.css("aside .declaration.at-rest .name").map(&:text)).to eq(%w[ContactCard])
    end

    it "closes the margin on the example's data class, in the page's own words" do
      expect(page.at("aside").element_children.last.text).
        to eq("Behind both: Contacts, where a visitor's contact is kept, standing in for your database.")
    end

    # Prev and next walk the running examples only; there is no next one yet.
    it "ends the article on the way back to every example" do
      pagination = page.at("article > nav[aria-label='Pagination']")

      expect(page.at("article").element_children.last).to eq(pagination)
      expect(pagination.css("a").map { |link| [link.text, link["href"]] }).to eq([["← All UI Examples", "/"]])
    end
  end

  # Asked of the ordering directly, not of a rendered page: Module#constants
  # happens to answer in the right order in this process, so a page would render
  # correctly with nothing ordering it at all.
  it "puts the data class before the components, whatever order they arrive in" do
    arriving = [ClickToEdit::ContactEditor, ClickToEdit::ContactCard, ClickToEdit::Contacts]

    ordered = described_class.in_reading_order(arriving)

    expect(ordered).to eq([ClickToEdit::Contacts, ClickToEdit::ContactCard, ClickToEdit::ContactEditor])
  end

  it "orders components among themselves by name" do
    arriving = [ClickToEdit::ContactEditor, ClickToEdit::ContactCard]

    expect(described_class.in_reading_order(arriving)).to eq(arriving.reverse)
  end

  # Both directions at once, for every example as it lands: a class nobody
  # described stops the page, and a description naming nothing is dead copy that
  # would otherwise sit in the file unnoticed.
  it "describes exactly the classes it is made of, on every live example page" do
    live_pages = Catalog.entries.select(&:live?).map do |entry|
      Object.const_get("#{entry.slug.tr('-', '_').camelize}Page")
    end

    expect(live_pages).not_to be_empty
    live_pages.each do |page_class|
      described = page_class.described_keys.sort
      classes = page_class.example_classes.map { |klass| page_class.key_for(klass) }.sort

      expect(described).to eq(classes), "#{page_class} describes #{described.inspect}, not #{classes.inspect}"
    end
  end
end
