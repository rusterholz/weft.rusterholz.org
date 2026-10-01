# frozen_string_literal: true

require "active_support/core_ext/string/filters"
require "nokogiri"
require "securerandom"

RSpec.describe UpdatingOtherContentPage do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  let(:page) { Nokogiri::HTML5(described_class.render) }
  let(:source_paths) do
    %w[contact_data contacts_table new_contact_form].map { |stem| "examples/v0.2/updating_other_content/#{stem}.rb" }
  end

  it "takes its heading and its title from the catalog" do
    expect(page.at("h1").text).to eq("Updating Other Content")
    expect(page.at("title").text).to eq("Updating Other Content · weft")
  end

  it "frames one How It Works between the heading and the source" do
    expect(page.css("h2").map(&:text)).to eq(["How It Works", "Pieces You Need"])
  end

  it "embeds the table and the form, live, side by side in one frame" do
    frame = page.at(".live-example")

    expect(frame.element_children.map { |child| child["id"] }).to eq(
      %w[updating-other-content-contacts-table updating-other-content-new-contact-form]
    )
  end

  it "says, right after the live example, what the two verbs are called in weft 0.3, linking the changelog" do
    callout = page.at(".live-example").next_element

    expect(callout["class"]).to eq("callout")
    expect(callout.at("p").text.squish).to eq("In weft 0.3, includes becomes brings and triggers becomes announces.")
    expect(callout.at("a").to_h).to include("href" => WEFT_NEXT_CHANGELOG_URL)
    expect(callout.at("a").text).to eq("Weft's Changelog")
  end

  it "names the decoupled variant in prose and shows no code it did not run" do
    article = page.at("article")

    expect(article.text).to include('refreshes on: "contact-added"')
    expect(article.css("pre").size).to eq(article.css("details pre").size)
  end

  it "lists every piece in reading order, the page last, each named and described" do
    pieces = page.css("h2:contains('Pieces You Need') + ul > li.piece")

    expect(pieces.map { |piece| piece.at(".about").text }).to eq(
      ["ContactData -- where a visitor's contacts are kept, standing in for your ORM model (SiteData::Records)",
       "ContactsTable -- the table the form updates from elsewhere on the page",
       "NewContactForm -- the form, and the one line that brings the table along",
       "UpdatingOtherContentPage -- a page to put them on (yours needs only the contacts_table and " \
       "new_contact_form calls; the rest is this walkthrough)"]
    )
    expect(pieces.map { |piece| piece.at("details pre").text }).to eq(
      [*source_paths, "examples/v0.2/updating_other_content_page.rb"].map do |path|
        File.read(File.join(APP_ROOT, path))
      end
    )
  end

  it "walks back to Reset User Input, and is the last running example" do
    links = page.css("nav[aria-label='Pagination'] a").map { |link| [link.text, link["href"]] }

    expect(links.first).to eq(["← Previous: Reset User Input", "/examples/reset-user-input"])
    expect(links.size).to eq(1)
  end

  it "gives no two elements the same id" do
    ids = page.css("[id]").map { |element| element["id"] }

    expect(ids.tally.select { |_id, count| count > 1 }).to be_empty
  end
end
