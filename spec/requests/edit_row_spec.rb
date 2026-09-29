# frozen_string_literal: true

require "nokogiri"

RSpec.describe "the Edit Row example" do
  let(:row_path) { "/_components/edit_row/person_row" }
  let(:editor_path) { "/_components/edit_row/person_row_editor" }

  def save(**overrides)
    post_form "#{editor_path}/save", { person_id: "2", name: "Angie M.", email: "angie@example.com" }.merge(overrides)
  end

  # Fragments are rows, so they are read where a row can stand.
  def row = Nokogiri::HTML5.fragment(last_response.body, context: "tbody").at("tr")

  def cells = row.css("> td").map { |cell| cell.text.strip }

  it "serves the example with the visitor's people in a table" do
    get "/examples/edit-row"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Angie MacDowell", "fuqua@tarkenton.org")
  end

  it "walks a visitor from a row to its editor and back to an edited row" do
    get "/examples/edit-row"
    get "#{row_path}/edit", person_id: "2"
    expect(row["id"]).to eq("edit-row-person-row-editor-2")
    expect(row.at("input[name=name]")["value"]).to eq("Angie MacDowell")

    save

    expect(row["id"]).to eq("edit-row-person-row-2")
    expect(cells).to eq(["Angie M.", "angie@example.com", "Edit"])
    get row_path, person_id: "2"
    expect(cells.first).to eq("Angie M.")
  end

  it "saves one row and leaves the others as they were" do
    get "/examples/edit-row"
    save

    get row_path, person_id: "1"

    expect(cells.first).to eq("Joe Smith")
  end

  it "cancels from the editor back to the row, unchanged" do
    get "/examples/edit-row"
    get "#{row_path}/edit", person_id: "2"

    # As htmx sends it: the editor's unset params serialize as JSON null, which reaches the wire as "null".
    get "#{editor_path}/cancel", person_id: "2", name: "null", email: "null"

    expect(last_response.status).to eq(200)
    expect(row["id"]).to eq("edit-row-person-row-2")
    expect(cells.first).to eq("Angie MacDowell")
  end

  it "answers Edit and Cancel only as GETs" do
    post_form "#{row_path}/edit", person_id: "2"
    expect(last_response.status).to eq(404)

    post_form "#{editor_path}/cancel", person_id: "2"
    expect(last_response.status).to eq(404)
  end

  it "refuses a save without the visitor's CSRF token" do
    get "/examples/edit-row"

    post "#{editor_path}/save", person_id: "2", name: "Mallory"

    expect(last_response.status).to eq(403)
    get row_path, person_id: "2"
    expect(cells.first).to eq("Angie MacDowell")
  end

  it "shows the next visitor the people as they started" do
    get "/examples/edit-row"
    save
    clear_cookies

    get row_path, person_id: "2"

    expect(cells.first).to eq("Angie MacDowell")
  end

  it "answers a person who does not exist, reading or saving, as not found" do
    get row_path, person_id: "does-not-exist"
    expect(last_response.status).to eq(404)

    save(person_id: "does-not-exist")
    expect(last_response.status).to eq(404)
  end

  it "does not serve the table as a fragment of its own" do
    get "/_components/edit_row/people_table"

    expect(last_response.status).to eq(404)
  end
end
