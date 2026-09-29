# frozen_string_literal: true

require "nokogiri"

# Which class answered, in the header the bench and the margin read: through the
# whole stack, as a visitor's browser gets it.
RSpec.describe "the Weft-Site-Handled header" do
  let(:card_path) { "/_components/click_to_edit/contact_card" }
  let(:editor_path) { "/_components/click_to_edit/contact_editor" }

  def handled = last_response.headers["weft-site-handled"]

  # The names the page just fetched carries in its margin, under one attribute.
  def margin_marks(attribute)
    Nokogiri::HTML5(last_response.body).css("aside.declarations [#{attribute}]").map { |node| node[attribute] }
  end

  it "names the component a fragment renders" do
    get card_path, contact_id: "1"

    expect(handled).to eq("ClickToEdit::ContactCard")
  end

  it "names the declaring component and the action on a GET transfer" do
    get "#{card_path}/edit", contact_id: "1"

    expect(handled).to eq("ClickToEdit::ContactCard#edit")
  end

  it "names the declaring component and the action on a POST transfer" do
    post_form "#{editor_path}/save", contact_id: "1", first_name: "Joseph"

    expect(last_response.status).to eq(200)
    expect(handled).to eq("ClickToEdit::ContactEditor#save")
  end

  it "names the page a full document renders" do
    get "/examples/click-to-edit"

    expect(handled).to eq("ClickToEditPage")
  end

  it "names the component even when it answers with its error" do
    get card_path, contact_id: "999"

    expect(last_response.status).to eq(404)
    expect(handled).to eq("ClickToEdit::ContactCard")
  end

  it "names nothing weft did not answer" do
    ["/static/css/site.css", "/_components/no_such_thing", "/no-such-page"].each do |path|
      get path
      expect(handled).to be_nil, path
    end
  end

  # The contract the page's script leans on: whatever the header says, the margin
  # has something marked with that name to light.
  it "names only what the example's margin can light, through the whole Click to Edit flow" do
    get "/examples/click-to-edit"
    blocks = margin_marks("data-component")
    declarations = margin_marks("data-handles")

    get card_path, contact_id: "1"
    rendered = handled
    actions = []
    get "#{card_path}/edit", contact_id: "1"
    actions << handled
    get "#{editor_path}/cancel", contact_id: "1"
    actions << handled
    post_form "#{editor_path}/save", contact_id: "1", first_name: "Joseph"
    actions << handled

    # An action is lit by its own declaration, so a header that dropped the action would light nothing.
    expect(blocks).to include(rendered)
    expect(actions.compact.size).to eq(3)
    expect(declarations).to include(*actions)
  end

  it "names only what the example's margin can light, through the whole Edit Row flow" do
    get "/examples/edit-row"
    blocks = margin_marks("data-component")
    declarations = margin_marks("data-handles")

    get "/_components/edit_row/person_row", person_id: "2"
    rendered = handled
    actions = []
    get "/_components/edit_row/person_row/edit", person_id: "2"
    actions << handled
    get "/_components/edit_row/person_row_editor/cancel", person_id: "2"
    actions << handled
    post_form "/_components/edit_row/person_row_editor/save", person_id: "2", name: "Angie M."
    actions << handled

    expect(blocks).to include(rendered)
    expect(actions).to eq(%w[EditRow::PersonRow#edit EditRow::PersonRowEditor#cancel EditRow::PersonRowEditor#save])
    expect(declarations).to include(*actions)
  end

  # Weft's router sees the path after Rack::Protection cleans it and Sinatra
  # decodes it, and the header has to name what the router served, no more.
  describe "at the edges of a path, agreeing with weft's router" do
    it "names nothing for a trailing slash, which weft answers 404" do
      get "#{card_path}/", contact_id: "1"

      expect(last_response.status).to eq(404)
      expect(handled).to be_nil
    end

    it "names the component under a doubled slash, which weft collapses" do
      get "/_components//click_to_edit/contact_card", contact_id: "1"

      expect(last_response.status).to eq(200)
      expect(handled).to eq("ClickToEdit::ContactCard")
    end

    it "names the component under a leading doubled slash" do
      get card_path, { contact_id: "1" }, "PATH_INFO" => "//_components/click_to_edit/contact_card"

      expect(last_response.status).to eq(200)
      expect(handled).to eq("ClickToEdit::ContactCard")
    end

    it "names an action spelled with percent-escapes, which weft decodes" do
      get "#{card_path}/%65dit", contact_id: "1"

      expect(last_response.status).to eq(200)
      expect(handled).to eq("ClickToEdit::ContactCard#edit")
    end

    it "names a page spelled with percent-escapes" do
      get "/examples/click%2Dto-edit"

      expect(last_response.status).to eq(200)
      expect(handled).to eq("ClickToEditPage")
    end

    it "names what a path with a parent step resolves to" do
      get "#{card_path}/../contact_card", contact_id: "1"

      expect(last_response.status).to eq(200)
      expect(handled).to eq("ClickToEdit::ContactCard")
    end

    it "names a page under a component's path, where the next segment is no action" do
      about_path = "#{card_path}/about"
      stub_const("CardAboutPage", Class.new(ApplicationPage) { self.page_path = about_path })

      get "#{card_path}/about"

      expect(last_response.status).to eq(200)
      expect(handled).to eq("CardAboutPage")
    ensure
      Weft.registry.evict(CardAboutPage)
    end
  end

  # The site's script moves the light only to a name the margin carries, so the
  # search, answering from the header on every page, leaves an example's light alone.
  it "names the search as nothing an example's margin carries" do
    get "/examples/click-to-edit"
    marks = margin_marks("data-component") + margin_marks("data-handles")

    get "/_components/search_results", q: "edit"

    expect(handled).to eq("SearchResults")
    expect(marks).not_to include(handled)
  end

  it "names nothing for an action the component does not declare for that verb" do
    post_form "#{card_path}/edit", contact_id: "1"

    expect(handled).to be_nil
  end
end
