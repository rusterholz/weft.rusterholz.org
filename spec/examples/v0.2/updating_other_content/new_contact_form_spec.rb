# frozen_string_literal: true

require "nokogiri"
require "securerandom"

RSpec.describe UpdatingOtherContent::NewContactForm do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  let(:wrapper) { Nokogiri::HTML5.fragment(described_class.render).at("div") }
  let(:form) { wrapper.at("form") }
  let(:add_path) { "/_components/updating_other_content/new_contact_form/add" }

  it "heads itself, then asks for a name and an email" do
    expect(wrapper.at("h3").text).to eq("Add a Contact")
    expect(form.css("label").to_h { |label| [label["for"], label.text.strip] }).to eq(
      "name" => "Name", "email" => "Email"
    )
    expect(form.css("input[name=name], input[name=email]").map { |input| input["value"] }).to eq([nil, nil])
  end

  it "adds over htmx and, without JavaScript, as a plain form post, carrying the visitor's CSRF token" do
    SiteData::Current.csrf_token = "this-visitors-token"

    expect(form.to_h).to include("hx-post" => add_path, "action" => add_path, "method" => "post",
                                 "hx-target" => "#updating-other-content-new-contact-form")
    expect(form.at("input[name=authenticity_token]")["value"]).to eq("this-visitors-token")
    expect(form.at("input[type=submit]")["value"]).to eq("Add Contact")
  end
end
