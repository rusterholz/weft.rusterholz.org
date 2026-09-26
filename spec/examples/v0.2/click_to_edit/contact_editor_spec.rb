# frozen_string_literal: true

require "json"
require "nokogiri"
require "securerandom"

RSpec.describe ClickToEdit::ContactEditor do
  before { Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  let(:editor) { Nokogiri::HTML5.fragment(described_class.render(contact_id: "1")).at("div") }
  let(:form) { editor.at("form") }

  def field_values
    form.css("input[type=text]").to_h { |input| [input["name"], input["value"]] }
  end

  it "fills each field from the visitor's store" do
    ClickToEdit::Contacts.update("1", email: "joseph@blow.com")

    expect(field_values).to eq("first_name" => "Joe", "last_name" => "Blow", "email" => "joseph@blow.com")
  end

  it "labels each field for its input" do
    labels = form.css("label").to_h { |label| [label["for"], label.text.strip] }

    expect(labels).to eq("first_name" => "First Name", "last_name" => "Last Name", "email" => "Email")
  end

  it "carries the contact it edits as a hidden field" do
    expect(form.at("input[type=hidden][name=contact_id]").to_h).to include("value" => "1")
  end

  it "carries the visitor's CSRF token as a hidden field" do
    Current.csrf_token = "this-visitors-token"

    expect(form.at("input[type=hidden][name=authenticity_token]")["value"]).to eq("this-visitors-token")
  end

  it "submits with a Save button" do
    expect(form.css("input[type=submit]").map { |input| input["value"] }).to eq(["Save"])
  end

  it "saves over htmx and, without JavaScript, as a plain form post" do
    save_path = "/_components/click_to_edit/contact_editor/save"

    expect(form.to_h).to include("hx-post" => save_path, "action" => save_path, "method" => "post",
                                 "hx-target" => "#click-to-edit-contact-editor-1", "hx-swap" => "outerHTML")
  end

  it "cancels with a button that cannot submit the form" do
    expect(form.at("button").text).to eq("Cancel")
    expect(form.at("button")["type"]).to eq("button")
  end

  it "hands its place back to the card with a GET, for the same contact" do
    cancel = form.at("button")

    expect(cancel["hx-get"]).to eq("/_components/click_to_edit/contact_editor/cancel")
    expect(JSON.parse(cancel["hx-vals"])).to include("contact_id" => "1")
    expect(cancel["hx-target"]).to eq("#click-to-edit-contact-editor-1")
    expect(cancel["hx-swap"]).to eq("outerHTML")
  end
end
