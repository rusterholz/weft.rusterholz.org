# frozen_string_literal: true

require "nokogiri"

RSpec.describe "the Updating Other Content example" do
  let(:form_path) { "/_components/updating_other_content/new_contact_form" }

  def add(name, email) = post_form("#{form_path}/add", name: name, email: email)

  def fragments = Nokogiri::HTML5.fragment(last_response.body).element_children

  def table_names(table) = table.css("tbody > tr > td:first-child").map(&:text)

  it "serves the example with the table and the form side by side" do
    get "/examples/updating-other-content"

    live = Nokogiri::HTML5(last_response.body).at(".live-example")
    expect(live.element_children.map { |child| child["id"] }).to eq(
      %w[updating-other-content-contacts-table updating-other-content-new-contact-form]
    )
  end

  # One request, one response, two regions.
  it "answers an add with the emptied form, and the table out of band, new row included" do
    get "/examples/updating-other-content"

    add("Angie MacDowell", "angie@macdowell.org")

    form, table = fragments
    expect(last_response.status).to eq(200)
    expect(form["id"]).to eq("updating-other-content-new-contact-form")
    expect(form.css("input[name=name], input[name=email]").map { |input| input["value"] }).to eq([nil, nil])
    expect(table["id"]).to eq("updating-other-content-contacts-table")
    expect(table["hx-swap-oob"]).to eq("true")
    expect(table_names(table)).to eq(["Joe Smith", "Angie MacDowell"])
  end

  it "keeps the contact for the visitor's next visit" do
    get "/examples/updating-other-content"
    add("Angie MacDowell", "angie@macdowell.org")

    get "/examples/updating-other-content"

    expect(table_names(Nokogiri::HTML5(last_response.body).at(".live-example"))).to eq(
      ["Joe Smith", "Angie MacDowell"]
    )
  end

  it "does not serve the table as a fragment of its own" do
    get "/_components/updating_other_content/contacts_table"

    expect(last_response.status).to eq(404)
  end

  it "refuses an add without the visitor's CSRF token" do
    get "/examples/updating-other-content"

    post "#{form_path}/add", name: "Mallory", email: "m@example.com"

    expect(last_response.status).to eq(403)
  end

  it "shows the next visitor only Joe" do
    get "/examples/updating-other-content"
    add("Angie MacDowell", "angie@macdowell.org")
    clear_cookies

    get "/examples/updating-other-content"

    expect(table_names(Nokogiri::HTML5(last_response.body).at(".live-example"))).to eq(["Joe Smith"])
  end
end
