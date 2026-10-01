# frozen_string_literal: true

require "nokogiri"

RSpec.describe "the Bulk Update example" do
  let(:roster_path) { "/_components/bulk_update/member_roster" }

  def bulk_update(ids) = post_form("#{roster_path}/update", ids.nil? ? {} : { active_ids: ids })

  def roster = Nokogiri::HTML5.fragment(last_response.body).at("#member-roster")

  def checked_ids = roster.css("input[type=checkbox][checked]").map { |box| box["value"] }

  def status = roster.at("> p")&.text

  it "serves the example with the visitor's members, three of four active" do
    get "/examples/bulk-update"

    expect(last_response.status).to eq(200)
    expect(Nokogiri::HTML5(last_response.body).css(".live-example input[checked]").size).to eq(3)
  end

  it "applies every box in one submit, and says how many flipped each way" do
    get "/examples/bulk-update"

    bulk_update(%w[1 2 4])

    expect(last_response.status).to eq(200)
    expect(checked_ids).to eq(%w[1 2 4])
    expect(status).to eq("Activated 1 and deactivated 1 members.")
  end

  # The browser sends nothing for no ticked boxes; the default turns that into "nobody".
  it "deactivates everyone when no box is ticked" do
    get "/examples/bulk-update"

    bulk_update(nil)

    expect(checked_ids).to be_empty
    expect(status).to eq("Activated 0 and deactivated 3 members.")
  end

  it "shows the saved state on the next visit, without the status" do
    get "/examples/bulk-update"
    bulk_update(%w[4])

    get roster_path

    expect(checked_ids).to eq(%w[4])
    expect(status).to be_nil
  end

  it "refuses an update without the visitor's CSRF token" do
    get "/examples/bulk-update"

    post "#{roster_path}/update", active_ids: []

    expect(last_response.status).to eq(403)
    get roster_path
    expect(checked_ids).to eq(%w[1 2 3])
  end

  it "shows the next visitor the members as they started" do
    get "/examples/bulk-update"
    bulk_update(nil)
    clear_cookies

    get roster_path

    expect(checked_ids).to eq(%w[1 2 3])
  end
end
