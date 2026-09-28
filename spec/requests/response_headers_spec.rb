# frozen_string_literal: true

require "base64"
require "digest"
require "nokogiri"

# What the browser is told about every response, through the whole stack: the
# refusals in front of the session included, since they answer before weft does.
RSpec.describe "response headers" do
  let(:policy) { SiteData::ResponseHeaders::CONTENT_SECURITY_POLICY }

  # One of each kind of response the site gives: a page, a fragment, a static
  # file, and a write refused before it reaches weft.
  def each_kind_of_response
    get "/"
    yield "page"
    get "/_components/click_to_edit/contact_card", contact_id: "1"
    yield "fragment"
    get "/static/css/site.css"
    yield "static file"
    refused_write
    yield "write refused for its token"
    refused_write("HTTP_ORIGIN" => "https://evil.example")
    yield "write refused for its Origin"
  end

  def refused_write(headers = {})
    post "/_components/theme_toggle/choose", { theme: "dark", return_to: "/" }, headers
    expect(last_response.status).to eq(403)
  end

  def pages = ["/", *SiteData::Catalog.entries.select(&:live?).map(&:path), "/no-such-page"]

  def policy_sources(directive) = policy[/(?:\A|; )#{directive} ([^;]*)/, 1].split

  it "carries the policy, HSTS, the referrer policy and nosniff on every kind of response" do
    each_kind_of_response do |kind|
      expect(last_response.headers).to include(
        "content-security-policy" => policy,
        "strict-transport-security" => "max-age=31536000",
        "referrer-policy" => "strict-origin-when-cross-origin",
        "x-content-type-options" => "nosniff"
      ), kind
    end
  end

  it "keeps fonts a year and scripts a day, and revalidates the rest" do
    get "/static/fonts/spectral-400.woff2"
    expect(last_response.headers["cache-control"]).to eq("private, max-age=31536000, immutable")
    get "/static/js/htmx.min.js"
    expect(last_response.headers["cache-control"]).to eq("private, max-age=86400")
    get "/examples/click-to-edit"
    expect(last_response.headers["cache-control"]).to eq("private, no-cache")
  end

  it "revalidates a font or script that is not there" do
    %w[/static/fonts/nope.woff2 /static/js/nope.js].each do |path|
      get path
      expect(last_response.status).to eq(404), path
      expect(last_response.headers["cache-control"]).to eq("private, no-cache"), path
    end
  end

  # A script the policy does not name is not run, and nothing on the server
  # notices: the page loads, and htmx is quietly misconfigured.
  it "allows every inline script any page carries, by its hash" do
    pages.each do |path|
      get path
      Nokogiri::HTML5(last_response.body).css("script:not([src])").each do |script|
        hash = "'sha256-#{Base64.strict_encode64(Digest::SHA256.digest(script.text))}'"
        expect(policy_sources("script-src")).to include(hash), "#{path}: #{script.text[0, 60].inspect}"
      end
    end
  end

  it "loads every script from this origin" do
    pages.each do |path|
      get path
      Nokogiri::HTML5(last_response.body).css("script[src]").each do |script|
        expect(script["src"]).to start_with("/"), "#{path}: #{script['src']}"
      end
    end
  end

  # htmx evaluates trigger filters, hx-on handlers and js: values as code, which
  # the policy does not allow, so they would fail in the browser without a word.
  it "asks htmx to evaluate nothing" do
    pages.each do |path|
      get path
      Nokogiri::HTML5(last_response.body).css("*").each do |element|
        element.attributes.each_value do |attribute|
          evaluates = attribute.name.start_with?("hx-on") ||
                      (attribute.name == "hx-trigger" && attribute.value.include?("[")) ||
                      attribute.value.match?(/\A\s*(js|javascript):/)
          expect(evaluates).to be(false), "#{path}: #{attribute.name}=#{attribute.value.inspect}"
        end
      end
    end
  end
end
