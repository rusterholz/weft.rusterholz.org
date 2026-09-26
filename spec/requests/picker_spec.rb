# frozen_string_literal: true

RSpec.describe "going where a picker points" do
  it "goes to the chosen page" do
    get "/_components/picker/go", to: "/examples/click-to-edit"

    expect(last_response).to be_redirect
    expect(last_response.headers["location"]).to end_with("/examples/click-to-edit")
  end

  it "never leaves the site" do
    get "/_components/picker/go", to: "https://elsewhere.example/"

    expect(last_response.headers["location"]).to end_with("example.org/")
  end
end
