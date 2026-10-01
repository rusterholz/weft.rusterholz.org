# frozen_string_literal: true

require "nokogiri"

RSpec.describe "the Reset User Input example" do
  let(:section_path) { "/_components/reset_user_input/comment_section" }

  def add(author, body) = post_form("#{section_path}/post", author: author, body: body)

  def section = Nokogiri::HTML5.fragment(last_response.body).at("#reset-user-input-comment-section")

  def authors = section.css("ul > li strong").map { |strong| strong.text.delete_suffix(": ") }

  it "serves the example with Rosa's comment and an empty form" do
    get "/examples/reset-user-input"

    expect(last_response.status).to eq(200)
    live = Nokogiri::HTML5(last_response.body).at(".live-example")
    expect(live.css("ul > li").size).to eq(1)
  end

  it "adds the comment and answers with the same section, its fields empty again" do
    get "/examples/reset-user-input"

    add("Elena", "See you there!")

    expect(last_response.status).to eq(200)
    expect(authors).to eq(%w[Rosa Elena])
    expect(section.css("form input[type=text]").map { |input| input["value"] }).to eq([nil, nil])
  end

  it "keeps the comment for the visitor's next visit" do
    get "/examples/reset-user-input"
    add("Elena", "See you there!")

    get section_path

    expect(authors).to eq(%w[Rosa Elena])
  end

  it "adds nothing for a blank name or comment, and answers as it stands" do
    get "/examples/reset-user-input"

    add("", "See you there!")
    add("Elena", "   ")

    expect(last_response.status).to eq(200)
    expect(authors).to eq(%w[Rosa])
  end

  it "refuses a comment without the visitor's CSRF token" do
    get "/examples/reset-user-input"

    post "#{section_path}/post", author: "Mallory", body: "Forged"

    expect(last_response.status).to eq(403)
  end

  it "shows the next visitor only Rosa's comment" do
    get "/examples/reset-user-input"
    add("Elena", "See you there!")
    clear_cookies

    get section_path

    expect(authors).to eq(%w[Rosa])
  end
end
