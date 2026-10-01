# frozen_string_literal: true

require "nokogiri"
require "securerandom"

RSpec.describe ResetUserInputPage do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  let(:page) { Nokogiri::HTML5(described_class.render) }
  let(:source_paths) do
    %w[comment_data comment_section].map { |stem| "examples/v0.2/reset_user_input/#{stem}.rb" }
  end

  it "takes its heading and its title from the catalog" do
    expect(page.at("h1").text).to eq("Reset User Input")
    expect(page.at("title").text).to eq("Reset User Input · weft")
  end

  it "frames one How It Works between the heading and the source" do
    expect(page.css("h2").map(&:text)).to eq(["How It Works", "Pieces You Need"])
  end

  it "embeds the visitor's own comments and the form, live, in a frame of their own" do
    ResetUserInput::CommentData.create(author: "Elena", body: "See you there!")

    frame = page.at(".live-example")

    expect(frame.element_children.map { |child| child["id"] }).to eq(["reset-user-input-comment-section"])
    expect(frame.css("ul > li").size).to eq(2)
  end

  it "introduces the example in prose before the comments" do
    intro = page.at(".live-example").xpath("preceding-sibling::p")

    expect(intro.size).to eq(3)
    expect(intro.first.text).to start_with("An add-a-comment form beneath a list of comments.")
  end

  it "lists every piece in reading order, the page last, each named and described" do
    pieces = page.css("h2:contains('Pieces You Need') + ul > li.piece")

    expect(pieces.map { |piece| piece.at(".about").text }).to eq(
      ["CommentData -- where a visitor's comments are kept, standing in for your ORM model (SiteData::Records)",
       "CommentSection -- the list and the form beneath it, one component",
       "ResetUserInputPage -- a page to put it on (yours needs only the comment_section call; " \
       "the rest is this walkthrough)"]
    )
    expect(pieces.map { |piece| piece.at("details pre").text }).to eq(
      [*source_paths, "examples/v0.2/reset_user_input_page.rb"].map { |path| File.read(File.join(APP_ROOT, path)) }
    )
  end

  # File Upload sits between them in the catalog, and is still to come.
  it "walks back to Inline Validation, the running example before it" do
    links = page.css("nav[aria-label='Pagination'] a").map { |link| [link.text, link["href"]] }

    expect(links.first).to eq(["← Previous: Inline Validation", "/examples/inline-validation"])
  end

  it "gives no two elements the same id" do
    ids = page.css("[id]").map { |element| element["id"] }

    expect(ids.tally.select { |_id, count| count > 1 }).to be_empty
  end
end
