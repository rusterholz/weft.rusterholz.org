# frozen_string_literal: true

# Puma splits a header value on its line breaks, so a control character that
# reaches Location or HX-Redirect can become a redirect somewhere else entirely.
# Rack::Test passes headers through untouched, which is why this asserts the
# characters themselves rather than where a browser would land.
RSpec.describe "redirects built from a request's own values" do
  let(:payloads) do
    ["/\r\nhttps://evil.example/", "/\r\n//evil.example/phish", "/\n//evil.example/", "/\t/x",
     "/\u0085//evil.example/", "/ //evil.example/"]
  end
  let(:not_utf8) { "/\xFF".b }

  def redirect_targets = last_response.headers.values_at("location", "hx-redirect").compact
  def unprintable = /[^\x21-\x7e]/

  it "never carry a control character, from the picker" do
    payloads.each do |to|
      get "/_components/version_picker/go", to: to

      expect(redirect_targets.join.b).not_to match(unprintable), to.inspect
    end
  end

  it "never carry a control character, from the theme toggle, with htmx or without" do
    payloads.product([{}, { "HTTP_HX_REQUEST" => "true" }]).each do |return_to, headers|
      post_form "/_components/theme_toggle/choose", { theme: "dark", return_to: return_to }, headers

      expect(redirect_targets.join.b).not_to match(unprintable), return_to.inspect
    end
  end

  it "go home from a target that is not UTF-8, rather than failing" do
    get "/_components/version_picker/go", to: not_utf8
    expect(last_response.headers["location"]).to eq("http://example.org/")

    post_form "/_components/theme_toggle/choose", theme: "dark", return_to: not_utf8
    expect(last_response.headers["location"]).to eq("http://example.org/")
  end
end
