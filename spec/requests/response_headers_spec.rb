# frozen_string_literal: true

require "base64"
require "digest"
require "json"
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

  it "keeps fonts a week and scripts a day, and revalidates the rest" do
    get "/static/fonts/spectral-400.woff2"
    expect(last_response.headers["cache-control"]).to eq("private, max-age=604800")
    get "/static/js/htmx.min.js"
    expect(last_response.headers["cache-control"]).to eq("private, max-age=86400")
    get "/static/js/site.js"
    expect(last_response.status).to eq(200)
    expect(last_response.headers["cache-control"]).to eq("private, max-age=86400")
    get "/examples/click-to-edit"
    expect(last_response.headers["cache-control"]).to eq("private, no-cache")
  end

  # So an expired font or script costs a 304, not the file again.
  it "answers a conditional request for a static file with a 304 that keeps its lifetime" do
    get "/static/fonts/spectral-400.woff2"
    last_modified = last_response.headers["last-modified"]

    get "/static/fonts/spectral-400.woff2", {}, "HTTP_IF_MODIFIED_SINCE" => last_modified

    expect(last_response.status).to eq(304)
    expect(last_response.headers["cache-control"]).to eq("private, max-age=604800")
  end

  it "revalidates a font or script that is not there" do
    %w[/static/fonts/nope.woff2 /static/js/nope.js].each do |path|
      get path
      expect(last_response.status).to eq(404), path
      expect(last_response.headers["cache-control"]).to eq("private, no-cache"), path
    end
  end

  # Every page, the error page included, and every fragment a page fetches with
  # hx-get, with the hx-vals it would send: one level deep, as rendered on arrival.
  def each_document(&)
    [*pages, ExplodingPage.page_path].each do |path|
      get path
      page = Nokogiri::HTML5(last_response.body)
      yield path, page
      each_fragment_of(page, &)
    end
  end

  def each_fragment_of(page)
    page.css("[hx-get]").each do |element|
      params = JSON.parse(element["hx-vals"] || "{}")
      where = "#{element['hx-get']} #{params}"
      get element["hx-get"], params
      expect(last_response.status).to be < 400, where
      yield where, Nokogiri::HTML5(last_response.body)
    end
  end

  # What htmx runs as code: hx-on handlers, hx-vars, trigger filters and js: values,
  # each also spelled with a data- prefix.
  def evaluates?(attribute)
    name = attribute.name.delete_prefix("data-")
    name.start_with?("hx-on") || name == "hx-vars" ||
      (name == "hx-trigger" && attribute.value.include?("[")) ||
      attribute.value.match?(/\A\s*(js|javascript):/)
  end

  # A script the policy does not name is not run, and nothing on the server
  # notices: the page loads, and htmx is quietly misconfigured.
  it "allows every inline script any page or fragment carries, by its hash" do
    each_document do |where, html|
      html.css("script:not([src])").each do |script|
        hash = "'sha256-#{Base64.strict_encode64(Digest::SHA256.digest(script.text))}'"
        expect(policy_sources("script-src")).to include(hash), "#{where}: #{script.text[0, 60].inspect}"
      end
    end
  end

  it "loads every script from this origin" do
    each_document do |where, html|
      html.css("script[src]").each do |script|
        expect(script["src"]).to start_with("/"), "#{where}: #{script['src']}"
      end
    end
  end

  # The policy does not allow evaluation, so any of these would fail in the
  # browser without a word.
  it "asks htmx to evaluate nothing, on any page or fragment" do
    each_document do |where, html|
      html.css("*").each do |element|
        element.attributes.each_value do |attribute|
          expect(evaluates?(attribute)).to be(false), "#{where}: #{attribute.name}=#{attribute.value.inspect}"
        end
      end
    end
  end

  it "recognizes every form htmx evaluates" do
    evaluating = Nokogiri::HTML5.fragment(<<~HTML).at("p")
      <p hx-on:click="x" hx-on::after-request="x" data-hx-on:click="x" hx-vars="x" data-hx-vars="x"
         hx-trigger="keyup[ctrlKey]" data-hx-trigger="keyup[ctrlKey]" hx-vals="js:{a: 1}"
         data-hx-vals="js:{a: 1}" href="javascript:void(0)"></p>
    HTML
    inert = Nokogiri::HTML5.fragment(%(<p hx-trigger="click" hx-vals='{"a":1}' data-hx-get="/x"></p>)).at("p")

    expect(evaluating.attributes.values.reject { |attribute| evaluates?(attribute) }.map(&:name)).to be_empty
    expect(inert.attributes.values.select { |attribute| evaluates?(attribute) }.map(&:name)).to be_empty
  end
end
