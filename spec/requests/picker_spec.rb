# frozen_string_literal: true

RSpec.describe "going where a picker points" do
  it "goes to the chosen page" do
    get "/_components/version_picker/go", to: "/examples/click-to-edit"

    expect(last_response).to be_redirect
    expect(last_response.headers["location"]).to end_with("/examples/click-to-edit")
  end

  it "answers the bare picker as not found, and the version picker on its own" do
    get "/_components/picker"
    expect(last_response.status).to eq(404)

    get "/_components/version_picker"
    expect(last_response.status).to eq(200)
  end

  it "never leaves the site" do
    get "/_components/version_picker/go", to: "https://elsewhere.example/"

    expect(last_response.headers["location"]).to end_with("example.org/")
  end
end
