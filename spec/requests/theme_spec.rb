# frozen_string_literal: true

require "nokogiri"

RSpec.describe "choosing a theme" do
  let(:choose) { "/_components/theme_toggle/choose" }

  def theme_on(path)
    get path
    last_response.body[/<html[^>]*data-theme="(\w+)"/, 1]
  end

  it "follows the system until the visitor chooses" do
    expect(theme_on("/")).to be_nil
  end

  it "keeps the visitor's choice, page after page" do
    post choose, theme: "dark", return_to: "/examples/click-to-edit"

    expect(theme_on("/")).to eq("dark")
    expect(theme_on("/examples/click-to-edit")).to eq("dark")
  end

  it "keeps one visitor's choice from another" do
    post choose, theme: "dark", return_to: "/"

    with_session(:other) { expect(theme_on("/")).to be_nil }
    expect(theme_on("/")).to eq("dark")
  end

  it "offers each page's toggle a way back to that page" do
    get "/examples/click-to-edit"

    return_to = Nokogiri::HTML5(last_response.body).css("#theme-toggle-dark input[name=return_to]").first
    expect(return_to["value"]).to eq("/examples/click-to-edit")
  end

  it "sends the visitor back to the page they chose it on" do
    post choose, theme: "light", return_to: "/examples/click-to-edit"

    expect(last_response).to be_redirect
    expect(last_response.headers["location"]).to end_with("/examples/click-to-edit")
  end

  it "sends htmx back the same way, as a full navigation" do
    post choose, { theme: "light", return_to: "/examples/click-to-edit" }, "HTTP_HX_REQUEST" => "true"

    expect(last_response.headers["hx-redirect"]).to eq("/examples/click-to-edit")
  end

  it "never sends anyone off the site" do
    post choose, theme: "light", return_to: "//elsewhere.example/phish"

    expect(last_response.headers["location"]).to end_with("example.org/")
  end

  it "answers the toggle fetched on its own sanely, whatever it is asked for" do
    get "/_components/theme_toggle"
    expect(last_response.status).to eq(404)

    get "/_components/theme_toggle", theme: "sepia"
    expect(last_response.status).to eq(404)

    get "/_components/theme_toggle", theme: "dark"
    expect(last_response.status).to eq(200)
  end

  it "ignores a theme it does not offer" do
    post choose, theme: "sepia", return_to: "/"

    expect(theme_on("/")).to be_nil
  end
end
