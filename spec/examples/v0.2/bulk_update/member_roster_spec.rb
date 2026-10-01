# frozen_string_literal: true

require "nokogiri"
require "securerandom"

RSpec.describe BulkUpdate::MemberRoster do
  before { SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}" }

  let(:roster) { Nokogiri::HTML5.fragment(described_class.render).at("div") }
  let(:form) { roster.at("form") }
  let(:update_path) { "/_components/bulk_update/member_roster/update" }

  def checked_ids(html = roster)
    html.css("input[type=checkbox][checked]").map { |box| box["value"] }
  end

  it "lists each member with a checkbox, ticked as the visitor's store has them" do
    BulkUpdate::MemberData.find("2").update(active: false)

    expect(form.css("tbody > tr > td:first-child").map(&:text)).to eq(
      ["Joe Smith", "Angie MacDowell", "Fuqua Tarkenton", "Kim Yee"]
    )
    expect(checked_ids).to eq(%w[1 3])
  end

  # The brackets are what fold every ticked box into one array param.
  it "names every checkbox active_ids[], valued with its member's id" do
    boxes = form.css("input[type=checkbox]")

    expect(boxes.map { |box| box["name"] }.uniq).to eq(["active_ids[]"])
    expect(boxes.map { |box| box["value"] }).to eq(%w[1 2 3 4])
  end

  # Weft leaves an array out of the id, so the boxes ticked never change it.
  it "keeps one id whatever is ticked, which its update aims at" do
    ticked = Nokogiri::HTML5.fragment(described_class.render(active_ids: %w[1 2])).at("div")

    expect([roster["id"], ticked["id"]]).to eq(%w[bulk-update-member-roster bulk-update-member-roster])
    expect(form.to_h).to include("hx-post" => update_path, "action" => update_path, "method" => "post",
                                 "hx-target" => "#bulk-update-member-roster", "hx-swap" => "outerHTML")
  end

  it "submits with a Bulk Update button, carrying the visitor's CSRF token" do
    SiteData::Current.csrf_token = "this-visitors-token"

    expect(form.css("input[type=submit]").map { |input| input["value"] }).to eq(["Bulk Update"])
    expect(form.at("input[type=hidden][name=authenticity_token]")["value"]).to eq("this-visitors-token")
  end

  it "says nothing until there is a status, then says it under the form" do
    expect(roster.css("> p")).to be_empty

    with_status = Nokogiri::HTML5.fragment(described_class.render(status: "Activated 1.")).at("div")

    expect(with_status.element_children.last.to_h).to eq({})
    expect(with_status.element_children.last.text).to eq("Activated 1.")
  end
end
