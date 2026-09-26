# frozen_string_literal: true

RSpec.describe "the Click to Edit example" do
  let(:card_path) { "/_components/click_to_edit/contact_card" }
  let(:editor_path) { "/_components/click_to_edit/contact_editor" }

  def save(**overrides)
    post_form "#{editor_path}/save",
              { contact_id: "1", first_name: "Joseph", last_name: "Blow", email: "joe@blow.com" }.merge(overrides)
  end

  it "serves the example at the slug weft's own docs use" do
    get "/examples/click-to-edit"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Joe")
    expect(last_response.body).to include("joe@blow.com")
  end

  it "walks a visitor from the card to the editor and back to an edited card" do
    get "/examples/click-to-edit"
    get "#{card_path}/edit", contact_id: "1"
    expect(last_response.body).to include('value="Joe"')

    save

    expect(last_response.body).to include("Joseph")
    get card_path, contact_id: "1"
    expect(last_response.body).to include("Joseph")
  end

  it "cancels from the editor back to the card, unchanged" do
    get "/examples/click-to-edit"
    get "#{card_path}/edit", contact_id: "1"

    # As htmx sends it: the editor's unset params serialize as JSON null, which reaches the wire as "null".
    get "#{editor_path}/cancel", contact_id: "1", first_name: "null", last_name: "null", email: "null"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('id="click-to-edit-contact-card-1"')
    expect(last_response.body).to include("Joe")
    expect(last_response.body).not_to include("<form")
  end

  # Edit and Cancel change nothing, so they are GETs; only saving is a POST.
  it "answers Edit and Cancel only as GETs" do
    post_form "#{card_path}/edit", contact_id: "1"
    expect(last_response.status).to eq(404)

    post_form "#{editor_path}/cancel", contact_id: "1"
    expect(last_response.status).to eq(404)
  end

  it "keeps the edit for the visitor who made it" do
    get "/examples/click-to-edit"
    save

    get "/examples/click-to-edit"

    expect(last_response.body).to include("Joseph")
  end

  # The card on its own, not the whole page: the page also shows the example's
  # source, which mentions the seeded name whatever the visitor has done to it.
  it "shows the next visitor the contact as it started" do
    get "/examples/click-to-edit"
    save
    clear_cookies

    get card_path, contact_id: "1"

    expect(last_response.body).to include("Joe")
    expect(last_response.body).not_to include("Joseph")
  end

  it "answers a contact that does not exist without spilling a stack trace" do
    get card_path, contact_id: "does-not-exist"

    expect(last_response.status).to eq(404)
    expect(last_response.body).not_to include("app/data/store.rb")
  end

  # Reading and writing a contact that is not there are the same question, so
  # they get the same answer. This file is the template for twenty more.
  it "answers a save for a contact that does not exist the way it answers a read" do
    save(contact_id: "does-not-exist")

    expect(last_response.status).to eq(404)
    expect(last_response.body).not_to include("KeyError")
  end

  it "leaves a field alone when the form does not send it" do
    get "/examples/click-to-edit"

    post_form "#{editor_path}/save", contact_id: "1", first_name: "Joseph"

    expect(last_response.body).to include("Joseph")
    expect(last_response.body).to include("Blow")
    expect(last_response.body).to include("joe@blow.com")
  end

  it "does not route the abstract page every example inherits from" do
    get "/example"

    expect(last_response.status).to eq(404)
  end

  # The path it would take is not on the wire, and it must stay that way: a
  # routable code block is a component that reads any file it is asked for.
  it "does not serve the code block as a fragment of its own" do
    get "/_components/code_block"

    expect(last_response.status).to eq(404)
  end
end
