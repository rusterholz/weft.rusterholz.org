# frozen_string_literal: true

require "nokogiri"

# Which class answered, in the header the bench and the margin read: through the
# whole stack, as a visitor's browser gets it.
RSpec.describe "the Weft-Site-Handled header" do
  let(:card_path) { "/_components/click_to_edit/contact_card" }
  let(:editor_path) { "/_components/click_to_edit/contact_editor" }

  def handled = last_response.headers["weft-site-handled"]

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
    margin = Nokogiri::HTML5(last_response.body).at("aside.declarations")
    lightable = margin.css("[data-component]").map { |block| block["data-component"] } +
                margin.css("[data-handles]").map { |declaration| declaration["data-handles"] }

    named = []
    get card_path, contact_id: "1"
    named << handled
    get "#{card_path}/edit", contact_id: "1"
    named << handled
    get "#{editor_path}/cancel", contact_id: "1"
    named << handled
    post_form "#{editor_path}/save", contact_id: "1", first_name: "Joseph"
    named << handled

    expect(named.compact.size).to eq(4)
    expect(lightable).to include(*named)
  end

  it "names nothing for an action the component does not declare for that verb" do
    post_form "#{card_path}/edit", contact_id: "1"

    expect(handled).to be_nil
  end
end
