# frozen_string_literal: true

require "json"
require "nokogiri"

# Every form that writes carries the session's token, and a POST without it is
# refused before it reaches a component: so another site cannot make a visitor's
# browser save, choose or reset on their behalf.
RSpec.describe "cross-site request forgery" do
  let(:writes) do
    {
      "/_components/click_to_edit/contact_editor/save" => { contact_id: "1", first_name: "Mallory" },
      "/_components/theme_toggle/choose" => { theme: "dark", return_to: "/" },
      "/_components/reset_example/reset" => { slug: "click-to-edit" }
    }
  end

  it "refuses a write that carries no token" do
    get "/"
    writes.each do |path, fields|
      post path, fields

      expect(last_response.status).to eq(403), path
    end
  end

  it "refuses a write that carries a token that is not the session's" do
    get "/"
    writes.each do |path, fields|
      post path, fields.merge(authenticity_token: "forged")

      expect(last_response.status).to eq(403), path
    end
  end

  it "refuses another visitor's token" do
    token = csrf_token
    clear_cookies
    get "/"

    post "/_components/theme_toggle/choose", theme: "dark", return_to: "/", authenticity_token: token

    expect(last_response.status).to eq(403)
  end

  it "accepts a write that carries the token its own page gave it" do
    token = csrf_token
    writes.each do |path, fields|
      post path, fields.merge(authenticity_token: token)

      expect(last_response.status).to be < 400, path
    end
  end

  describe "as a header, for htmx writes that have no form" do
    # The header every htmx request inherits from the page, as the page sets it.
    def page_headers
      get "/examples/click-to-edit"
      JSON.parse(Nokogiri::HTML5(last_response.body).at("html")["hx-headers"])
    end

    # Masked afresh on each render, so it matches the form field on the same page.
    it "gives every page the session's token for htmx to send on each request" do
      get "/"
      page = Nokogiri::HTML5(last_response.body)

      expect(JSON.parse(page.at("html")["hx-headers"])).to eq(
        "X-CSRF-Token" => page.at("input[name=authenticity_token]")["value"]
      )
    end

    it "accepts a write whose only token is the header" do
      headers = page_headers

      post "/_components/click_to_edit/contact_editor/save", { contact_id: "1", first_name: "Joseph" },
           "HTTP_X_CSRF_TOKEN" => headers.fetch("X-CSRF-Token")

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Joseph")
    end

    it "refuses a header token that is not the session's" do
      get "/"

      post "/_components/click_to_edit/contact_editor/save", { contact_id: "1", first_name: "Mallory" },
           "HTTP_X_CSRF_TOKEN" => "forged"

      expect(last_response.status).to eq(403)
    end
  end

  it "puts the token in every form that writes" do
    get "/examples/click-to-edit"
    page = Nokogiri::HTML5(last_response.body)
    get "/_components/click_to_edit/contact_card/edit", contact_id: "1"
    editor = Nokogiri::HTML5.fragment(last_response.body)

    [*page.css("form[method=post]"), *editor.css("form")].each do |form|
      expect(form.at("input[type=hidden][name=authenticity_token]")&.[]("value")).to be_present, form.to_html
    end
  end
end
