# frozen_string_literal: true

require "json"
require "nokogiri"

RSpec.describe "the Delete Row example" do
  let(:row_path) { "/_components/delete_row/contact_row" }

  # The token as the page hands it to htmx, which sends it as a header on every request.
  def page_token
    get "/examples/delete-row"
    JSON.parse(Nokogiri::HTML5(last_response.body).at("html")["hx-headers"]).fetch("X-CSRF-Token")
  end

  def destroy(contact_id, token:)
    headers = { "HTTP_HX_REQUEST" => "true" }
    headers["HTTP_X_CSRF_TOKEN"] = token if token
    delete "#{row_path}/destroy", { contact_id: contact_id }, headers
  end

  def shown_names
    get "/examples/delete-row"
    Nokogiri::HTML5(last_response.body).css(".live-example tbody > tr").map { |row| row.at("td").text }
  end

  it "serves the example with the visitor's contacts in a table" do
    expect(shown_names).to eq(["Angie MacDowell", "Fuqua Tarkenton", "Kim Yee"])
  end

  it "deletes a contact, answering with nothing, and the table no longer has it" do
    destroy("2", token: page_token)

    expect(last_response.status).to eq(200)
    expect(last_response.body).to be_empty
    expect(shown_names).to eq(["Angie MacDowell", "Kim Yee"])
  end

  it "refuses a DELETE without the token, and keeps the contact" do
    get "/examples/delete-row"

    destroy("2", token: nil)

    expect(last_response.status).to eq(403)
    expect(shown_names).to include("Fuqua Tarkenton")
  end

  it "refuses a DELETE carrying a token that is not the session's" do
    get "/examples/delete-row"

    destroy("2", token: "forged")

    expect(last_response.status).to eq(403)
  end

  it "answers delete only as a DELETE" do
    post_form "#{row_path}/destroy", contact_id: "2"

    expect(last_response.status).to eq(404)
  end

  it "answers a contact already deleted as not found, in the row's place" do
    token = page_token
    destroy("2", token: token)

    destroy("2", token: token)

    error = Nokogiri::HTML5.fragment(last_response.body, context: "tbody").element_children.first
    expect(last_response.status).to eq(404)
    expect(last_response.headers["hx-reswap"]).to eq("outerHTML")
    expect([error.name, error["id"]]).to eq(%w[tr delete-row-contact-row-2])
    get row_path, contact_id: "2"
    expect(last_response.status).to eq(404)
  end

  it "shows the next visitor the contacts as they started" do
    destroy("2", token: page_token)
    clear_cookies

    get row_path, contact_id: "2"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Fuqua Tarkenton")
  end

  it "does not serve the table as a fragment of its own" do
    get "/_components/delete_row/contact_book_table"

    expect(last_response.status).to eq(404)
  end
end
