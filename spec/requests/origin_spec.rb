# frozen_string_literal: true

# A write whose Origin names another site is refused outright, and the visitor
# keeps their session. Without the refusal ahead of the session, weft's own
# protection clears the session and lets the write through, so a proxy that
# reports the wrong scheme or host shows up only as "my edit vanished".
RSpec.describe "a write from another origin" do
  let(:card_path) { "/_components/click_to_edit/contact_card" }
  let(:save_path) { "/_components/click_to_edit/contact_editor/save" }

  def save(first_name, origin:)
    post save_path, { contact_id: "1", first_name: first_name, authenticity_token: csrf_token },
         "HTTP_ORIGIN" => origin
  end

  it "is accepted when the Origin is this site's own" do
    save("Joseph", origin: "http://example.org")

    expect(last_response.status).to eq(200)
    get card_path, contact_id: "1"
    expect(last_response.body).to include("Joseph")
  end

  it "is refused, even carrying the session's token" do
    save("Mallory", origin: "https://evil.example")

    expect(last_response.status).to eq(403)
  end

  it "leaves the visitor's session and earlier edits alone" do
    save("Joseph", origin: "http://example.org")

    save("Mallory", origin: "https://evil.example")

    get card_path, contact_id: "1"
    expect(last_response.body).to include("Joseph")
    expect(last_response.body).not_to include("Mallory")
  end
end
