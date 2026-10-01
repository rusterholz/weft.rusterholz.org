# frozen_string_literal: true

require "nokogiri"
require "securerandom"

RSpec.describe InlineValidation::SignupEmailField do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  def field(**params) = Nokogiri::HTML5.fragment(described_class.render(**params)).at("div")

  let(:validate_path) { "/_components/inline_validation/signup_email_field/validate" }

  # A changing email cannot anchor a DOM id, so the field pins its own.
  it "keeps one id, which its validation aims at" do
    form = field.at("form")

    expect(field["id"]).to eq("signup-email-field")
    expect(form.to_h).to include("hx-post" => validate_path, "hx-target" => "#signup-email-field",
                                 "hx-swap" => "outerHTML", "hx-trigger" => "change")
  end

  it "asks for an email in a labeled field, carrying the visitor's CSRF token" do
    SiteData::Current.csrf_token = "this-visitors-token"
    form = field.at("form")

    expect(form.at("label[for=email]").text.strip).to eq("Email Address")
    expect(form.at("input#email").to_h).to include("type" => "email", "name" => "email")
    expect(form.at("input[name=authenticity_token]")["value"]).to eq("this-visitors-token")
  end

  # A browser checking an email field itself stops htmx sending what it rejects,
  # leaving the last verdict beside new text. The server is the one that decides.
  it "leaves the checking to the server" do
    expect(field.at("form")).to have_attribute("novalidate")
  end

  it "says nothing before anything is typed" do
    expect(field.css("p")).to be_empty
    expect(field["class"].to_s.split).not_to include("valid", "invalid")
  end

  it "echoes what was typed and marks itself valid when there is no complaint" do
    rendered = field(email: "maria@example.com")

    expect(rendered.at("input#email")["value"]).to eq("maria@example.com")
    expect(rendered["class"].split).to include("valid")
    expect(rendered.at("p").text).to eq("maria@example.com looks good.")
  end

  it "shows a complaint and marks itself invalid, keeping what was typed" do
    rendered = field(email: "not-an-email", error_message: "That doesn't look like an email address.")

    expect(rendered.at("input#email")["value"]).to eq("not-an-email")
    expect(rendered["class"].split).to include("invalid")
    expect(rendered.at("p").text).to eq("That doesn't look like an email address.")
  end
end
