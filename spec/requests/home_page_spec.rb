# frozen_string_literal: true

RSpec.describe "the home page" do
  it "serves a document at the site root" do
    get "/"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("<h1>weft</h1>")
  end

  it "lists the examples that are running, and only those" do
    get "/"

    expect(last_response.body).to include(%(<a href="/examples/click-to-edit">Click to Edit</a>))
    expect(last_response.body).not_to include("/examples/live-ticker")
  end

  # The standing constraint made executable: nothing the running site loads
  # comes from a third party. If include_htmx is ever flipped back on, the gem
  # emits its pinned unpkg URL and the second expectation catches it.
  it "loads htmx from this site's own origin" do
    get "/"

    expect(last_response.body).to include("/static/js/htmx.min.js")
    expect(last_response.body).not_to include("unpkg.com")
  end

  it "serves the vendored htmx file the page points at" do
    get "/static/js/htmx.min.js"

    expect(last_response.status).to eq(200)
  end

  # The title is the discriminator: the gem ships its own not-found document, so
  # asserting on generic wording would pass even with our page unwired.
  it "answers an unknown path with the site's own not-found page" do
    get "/no/such/page"

    expect(last_response.status).to eq(404)
    expect(last_response.body).to include("<title>Not Found · weft</title>")
  end
end
