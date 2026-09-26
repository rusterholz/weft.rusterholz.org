# frozen_string_literal: true

# Puma splits a header value on its line breaks, so a control character that
# reaches Location or HX-Redirect can become a redirect somewhere else entirely.
# Rack::Test passes headers through untouched, which is why this asserts the
# characters themselves rather than where a browser would land.
RSpec.describe "redirects built from a request's own values" do
  let(:payloads) { ["/\r\nhttps://evil.example/", "/\r\n//evil.example/phish", "/\n//evil.example/", "/\t/x"] }

  def redirect_targets = last_response.headers.values_at("location", "hx-redirect").compact

  it "never carry a control character, from the picker" do
    payloads.each do |to|
      get "/_components/version_picker/go", to: to

      expect(redirect_targets.join).not_to match(/[\x00-\x1f\x7f]/), to.inspect
    end
  end

  it "never carry a control character, from the theme toggle, with htmx or without" do
    payloads.product([{}, { "HTTP_HX_REQUEST" => "true" }]).each do |return_to, headers|
      post_form "/_components/theme_toggle/choose", { theme: "dark", return_to: return_to }, headers

      expect(redirect_targets.join).not_to match(/[\x00-\x1f\x7f]/), return_to.inspect
    end
  end
end
