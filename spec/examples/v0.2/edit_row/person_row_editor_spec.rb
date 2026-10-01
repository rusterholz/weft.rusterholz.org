# frozen_string_literal: true

require "json"
require "nokogiri"
require "securerandom"

RSpec.describe EditRow::PersonRowEditor do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  let(:row) { Nokogiri::HTML5.fragment(described_class.render(person_id: "2"), context: "tbody").at("tr") }
  let(:form) { row.at("form") }
  let(:save_path) { "/_components/edit_row/person_row_editor/save" }

  it "is a table row, its fields in the cells the display row shows them in" do
    cells = row.css("> td")

    expect(cells.size).to eq(3)
    expect(cells[0].at("input")["name"]).to eq("name")
    expect(cells[1].at("input")["name"]).to eq("email")
    expect(cells[2].at("form")).not_to be_nil
  end

  it "fills each field from the visitor's store" do
    EditRow::PersonData.find("2").update(email: "angie@example.com")

    values = row.css("td > input[type=text]").to_h { |input| [input["name"], input["value"]] }

    expect(values).to eq("name" => "Angie MacDowell", "email" => "angie@example.com")
  end

  # A form cannot span table cells, so the fields in the other cells join it by its id.
  it "ties the fields in the other cells to the form in the last" do
    expect(form["id"]).to eq("save-person-2")
    expect(row.css("td > input[type=text]").map { |input| input["form"] }).to eq(%w[save-person-2 save-person-2])
  end

  it "takes its DOM id from the person it edits" do
    expect(row["id"]).to eq("edit-row-person-row-editor-2")
  end

  it "carries the person it edits, and the visitor's CSRF token, as hidden fields" do
    SiteData::Current.csrf_token = "this-visitors-token"

    expect(form.at("input[type=hidden][name=person_id]")["value"]).to eq("2")
    expect(form.at("input[type=hidden][name=authenticity_token]")["value"]).to eq("this-visitors-token")
  end

  it "saves over htmx and, without JavaScript, as a plain form post, back into the row's place" do
    expect(form.to_h).to include("hx-post" => save_path, "action" => save_path, "method" => "post",
                                 "hx-target" => "#edit-row-person-row-editor-2", "hx-swap" => "outerHTML")
    expect(form.css("input[type=submit]").map { |input| input["value"] }).to eq(["Save"])
  end

  it "hands its place back to the display row with a GET, from a button that cannot submit" do
    cancel = form.at("button")

    expect(cancel.text).to eq("Cancel")
    expect(cancel["type"]).to eq("button")
    expect(cancel["hx-get"]).to eq("/_components/edit_row/person_row_editor/cancel")
    expect(JSON.parse(cancel["hx-vals"])).to include("person_id" => "2")
    expect(cancel["hx-target"]).to eq("#edit-row-person-row-editor-2")
  end
end
