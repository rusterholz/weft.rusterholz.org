# frozen_string_literal: true

require "active_support/core_ext/string/filters"
require "nokogiri"
require "securerandom"

RSpec.describe ResetUserInput::CommentSection do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  def section(**params) = Nokogiri::HTML5.fragment(described_class.render(**params)).at("div")

  let(:form) { section.at("form") }
  let(:post_path) { "/_components/reset_user_input/comment_section/post" }

  it "lists the visitor's comments, each under its author" do
    ResetUserInput::CommentData.create(author: "Elena", body: "See you there!")

    expect(section.css("ul > li").map { |item| item.text.squish }).to eq(
      ["Rosa: Lovely event, and count me in for next year.", "Elena: See you there!"]
    )
  end

  it "takes its DOM id from no author, so it keeps the one the wiring aims at" do
    expect(section["id"]).to eq("reset-user-input-comment-section")
    expect(form.to_h).to include("hx-post" => post_path, "hx-target" => "#reset-user-input-comment-section",
                                 "hx-swap" => "outerHTML", "action" => post_path, "method" => "post")
  end

  # Whatever arrives, the fields render empty: that is the whole of the reset.
  it "renders its fields with no value, even when handed one" do
    fields = section(author: "Elena", body: "See you there!").css("form input[type=text]")

    expect(fields.map { |input| [input["name"], input["value"]] }).to eq([["author", nil], ["body", nil]])
  end

  it "labels each field and carries the visitor's CSRF token" do
    SiteData::Current.csrf_token = "this-visitors-token"

    expect(form.css("label").to_h { |label| [label["for"], label.text.strip] }).to eq(
      "author" => "Name", "body" => "Comment"
    )
    expect(form.at("input[name=authenticity_token]")["value"]).to eq("this-visitors-token")
    expect(form.at("input[type=submit]")["value"]).to eq("Add Comment")
  end
end
