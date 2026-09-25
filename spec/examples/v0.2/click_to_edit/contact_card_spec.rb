# frozen_string_literal: true

require "nokogiri"
require "securerandom"

RSpec.describe ClickToEdit::ContactCard do
  before { Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  let(:card) { Nokogiri::HTML5.fragment(described_class.render(contact_id: "1")).at("div") }

  def shown_fields
    card.css("> div").to_h do |row|
      label = row.at("strong")
      [label.text.strip, row.xpath("text()").text.strip]
    end
  end

  it "shows the contact as the visitor's store has it" do
    expect(shown_fields).to eq("First Name:" => "Joe", "Last Name:" => "Blow", "Email:" => "joe@blow.com")
  end

  it "shows an edit the visitor has saved" do
    ClickToEdit::Contacts.update("1", first_name: "Joseph")

    expect(shown_fields["First Name:"]).to eq("Joseph")
  end

  it "takes its DOM id from the contact it shows" do
    expect(card["id"]).to eq("click-to-edit-contact-card-1")
  end

  it "opens the editor for the same contact in its own place" do
    button = card.at("button")

    expect(button.text).to eq("Click To Edit")
    expect(button["hx-get"]).to eq("/_components/click_to_edit/contact_editor?contact_id=1")
    expect(button["hx-target"]).to eq("#click-to-edit-contact-card-1")
    expect(button["hx-swap"]).to eq("outerHTML")
  end

  it "refuses a contact the visitor does not have" do
    expect { described_class.render(contact_id: "does-not-exist") }.to raise_error(Weft::NotFound)
  end
end
