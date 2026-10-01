# frozen_string_literal: true

require "nokogiri"
require "securerandom"

RSpec.describe InlineValidationPage do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  let(:page) { Nokogiri::HTML5(described_class.render) }
  let(:source_paths) do
    %w[email_data signup_email_field].map { |stem| "examples/v0.2/inline_validation/#{stem}.rb" }
  end

  it "takes its heading and its title from the catalog" do
    expect(page.at("h1").text).to eq("Inline Validation")
    expect(page.at("title").text).to eq("Inline Validation · weft")
  end

  # Nothing here is kept, so a reset would do nothing.
  it "offers no Reset This Example" do
    expect(page.css(".reset-example")).to be_empty
    expect(page.at("article > h1").next_element.name).to eq("p")
  end

  it "frames one How It Works between the heading and the source" do
    expect(page.css("h2").map(&:text)).to eq(["How It Works", "Pieces You Need"])
  end

  it "embeds the empty field, live, in a frame of its own" do
    frame = page.at(".live-example")

    expect(frame.element_children.map { |child| child["id"] }).to eq(["signup-email-field"])
    expect(frame.css("p")).to be_empty
  end

  it "introduces the example in prose before the field" do
    intro = page.at(".live-example").xpath("preceding-sibling::p")

    expect(intro.size).to eq(3)
    expect(intro.first.text).to start_with("A signup form's email field that checks itself.")
  end

  it "lists every piece in reading order, the page last, each named and described" do
    pieces = page.css("h2:contains('Pieces You Need') + ul > li.piece")

    expect(pieces.map { |piece| piece.at(".about").text }).to eq(
      ["EmailData -- the addresses already registered, standing in for your database's uniqueness check",
       "SignupEmailField -- the field, its check, and its verdict",
       "InlineValidationPage -- a page to put it on (yours needs only the signup_email_field call; " \
       "the rest is this walkthrough)"]
    )
    expect(pieces.map { |piece| piece.at("details pre").text }).to eq(
      [*source_paths, "examples/v0.2/inline_validation_page.rb"].map { |path| File.read(File.join(APP_ROOT, path)) }
    )
  end

  it "walks back to Bulk Update, the running example before it" do
    links = page.css("nav[aria-label='Pagination'] a").map { |link| [link.text, link["href"]] }

    expect(links.first).to eq(["← Previous: Bulk Update", "/examples/bulk-update"])
  end

  it "gives no two elements the same id" do
    ids = page.css("[id]").map { |element| element["id"] }

    expect(ids.tally.select { |_id, count| count > 1 }).to be_empty
  end
end
