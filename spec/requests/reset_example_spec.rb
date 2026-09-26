# frozen_string_literal: true

RSpec.describe "resetting an example" do
  let(:reset) { "/_components/reset_example/reset" }
  let(:card) { "/_components/click_to_edit/contact_card" }

  before do
    get "/examples/click-to-edit"
    post "/_components/click_to_edit/contact_editor/save", contact_id: "1", first_name: "Joseph"
  end

  it "puts the visitor's copy back as it started, and returns to the example" do
    post reset, slug: "click-to-edit"

    expect(last_response).to be_redirect
    expect(last_response.headers["location"]).to end_with("/examples/click-to-edit")
    get card, contact_id: "1"
    expect(last_response.body).to include("Joe")
    expect(last_response.body).not_to include("Joseph")
  end

  it "answers an example that does not exist as not found" do
    post reset, slug: "no-such-example"

    expect(last_response.status).to eq(404)
  end

  it "answers an example that is not running yet as not found" do
    post reset, slug: "tabs"

    expect(last_response.status).to eq(404)
  end
end
