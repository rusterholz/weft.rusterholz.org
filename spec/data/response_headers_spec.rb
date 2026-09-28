# frozen_string_literal: true

require "rack/mock_request"

RSpec.describe SiteData::ResponseHeaders do
  def headers_for(path, inner_headers = {}, status: 200)
    inner = ->(_env) { [status, inner_headers.dup, ["ok"]] }
    _status, headers, _body = described_class.new(inner).call(Rack::MockRequest.env_for(path))
    headers
  end

  describe "on every response" do
    subject(:headers) { headers_for("/") }

    it "sets the content security policy" do
      expect(headers["content-security-policy"]).to eq(described_class::CONTENT_SECURITY_POLICY)
    end

    it "tells browsers to use https for a year" do
      expect(headers["strict-transport-security"]).to eq("max-age=31536000")
    end

    it "sends only the origin to other sites" do
      expect(headers["referrer-policy"]).to eq("strict-origin-when-cross-origin")
    end

    it "forbids content sniffing" do
      expect(headers["x-content-type-options"]).to eq("nosniff")
    end
  end

  describe "the content security policy" do
    subject(:policy) { described_class::CONTENT_SECURITY_POLICY }

    it "loads scripts only from this origin, plus the one inline script weft writes" do
      expect(policy).to include("script-src 'self' 'sha256-")
      expect(policy).not_to include("unsafe-eval")
    end

    it "refuses anything it does not name" do
      expect(policy).to start_with("default-src 'none'")
    end
  end

  describe "caching" do
    it "keeps a font for a week, since its URL carries no version either" do
      expect(headers_for("/static/fonts/spectral-400.woff2")["cache-control"]).to eq("private, max-age=604800")
    end

    it "keeps a vendored script for a day, since its URL carries no version" do
      expect(headers_for("/static/js/htmx.min.js")["cache-control"]).to eq("private, max-age=86400")
    end

    it "revalidates everything else, and keeps it out of shared caches" do
      %w[/ /examples/click-to-edit /_components/click_to_edit/contact_card /static/css/site.css].each do |path|
        expect(headers_for(path)["cache-control"]).to eq("private, no-cache"), path
      end
    end

    # A missing file kept for a week would stay missing for a week after it is added.
    it "revalidates a font or script that was not found" do
      %w[/static/fonts/nope.woff2 /static/js/nope.js].each do |path|
        expect(headers_for(path, status: 404)["cache-control"]).to eq("private, no-cache"), path
      end
    end

    it "keeps the long lifetime on a not-modified answer" do
      expect(headers_for("/static/fonts/spectral-400.woff2", status: 304)["cache-control"]).
        to eq("private, max-age=604800")
    end

    it "leaves a cache policy the application chose alone" do
      expect(headers_for("/", { "cache-control" => "no-store" })["cache-control"]).to eq("no-store")
    end
  end
end
