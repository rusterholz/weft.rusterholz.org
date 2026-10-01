# frozen_string_literal: true

require "nokogiri"

RSpec.describe "the Inline Validation example" do
  let(:validate_path) { "/_components/inline_validation/signup_email_field/validate" }

  def validate(email) = post_form(validate_path, email: email)

  def field = Nokogiri::HTML5.fragment(last_response.body).at("#signup-email-field")

  def verdict = [last_response.status, field["class"].split & %w[valid invalid], field.at("p")&.text]

  it "serves the example with an empty email field" do
    get "/examples/inline-validation"

    expect(last_response.status).to eq(200)
    expect(Nokogiri::HTML5(last_response.body).at(".live-example input#email")["value"]).to be_nil
  end

  it "answers an address that is not one with a 422 and the complaint, keeping what was typed" do
    validate("not-an-email")

    expect(verdict).to eq([422, ["invalid"], "That doesn't look like an email address."])
    expect(field.at("input#email")["value"]).to eq("not-an-email")
  end

  # The next change aims at #signup-email-field, so a complaint must land wearing that id too.
  it "keeps its id through a complaint, so the next check still finds it" do
    validate("not-an-email")
    expect(Nokogiri::HTML5.fragment(last_response.body).element_children.first["id"]).to eq("signup-email-field")

    validate("maria@example.com")
    expect(verdict).to eq([200, ["valid"], "maria@example.com looks good."])
  end

  it "answers an address already registered with a 422 naming it" do
    validate("taken@example.com")

    expect(verdict).to eq([422, ["invalid"], "taken@example.com is already registered."])
  end

  it "answers a good address with a 200 and the all-clear" do
    validate("maria@example.com")

    expect(verdict).to eq([200, ["valid"], "maria@example.com looks good."])
  end

  it "complains about an empty field rather than passing it" do
    validate("")

    expect(verdict.first(2)).to eq([422, ["invalid"]])
  end

  it "refuses a check without the visitor's CSRF token" do
    get "/examples/inline-validation"

    post validate_path, email: "maria@example.com"

    expect(last_response.status).to eq(403)
  end
end
