# frozen_string_literal: true

require "cgi"

RSpec.describe "the Click to Edit example" do
  let(:card_path) { "/_components/click_to_edit/contact_card" }
  let(:editor_path) { "/_components/click_to_edit/contact_editor" }
  # In reading order: the data class, then the components.
  let(:source_files) do
    %w[contacts contact_card contact_editor].map do |stem|
      File.join(EXAMPLES_ROOT, "click_to_edit", "#{stem}.rb")
    end
  end

  def shown_code_blocks
    last_response.body.scan(%r{<pre>(.*?)</pre>}m).map { |block| CGI.unescapeHTML(block.first.gsub(/<[^>]+>/, "")) }
  end

  def save(**overrides)
    post "#{editor_path}/save",
         { contact_id: "1", first_name: "Joseph", last_name: "Blow", email: "joe@blow.com" }.merge(overrides)
  end

  it "serves the example at the slug weft's own docs use" do
    get "/examples/click-to-edit"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Joe")
    expect(last_response.body).to include("joe@blow.com")
  end

  it "takes its heading and its title from the catalog" do
    get "/examples/click-to-edit"

    expect(last_response.body).to include("<h1>Click to Edit</h1>")
    expect(last_response.body).to include("<title>Click to Edit · weft</title>")
  end

  it "walks a visitor from the card to the editor and back to an edited card" do
    get "/examples/click-to-edit"
    get editor_path, contact_id: "1"
    expect(last_response.body).to include('value="Joe"')

    save

    expect(last_response.body).to include("Joseph")
    get card_path, contact_id: "1"
    expect(last_response.body).to include("Joseph")
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

    post "#{editor_path}/save", contact_id: "1", first_name: "Joseph"

    expect(last_response.body).to include("Joseph")
    expect(last_response.body).to include("Blow")
    expect(last_response.body).to include("joe@blow.com")
  end

  # Not a sample of the code: every file the example is made of, whole and
  # unaltered, one block each. Nothing here can drift from the classes that
  # rendered the card above it.
  it "shows each of the example's files exactly as it is on disk, in reading order" do
    get "/examples/click-to-edit"

    expect(shown_code_blocks).to eq(source_files.map { |file| File.read(file) })
    expect(last_response.body).to include("<span class=")
  end

  it "labels each block with the file it read" do
    get "/examples/click-to-edit"

    expect(last_response.body).to include("<code>examples/v0.2/click_to_edit/contacts.rb</code>")
  end

  it "links the source of the page and of every file the example is made of" do
    get "/examples/click-to-edit"

    expect(last_response.body).to include("/examples/v0.2/click_to_edit_page.rb")
    expect(last_response.body).to include("/examples/v0.2/click_to_edit/contact_editor.rb")
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
