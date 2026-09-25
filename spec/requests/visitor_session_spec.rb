# frozen_string_literal: true

RSpec.describe "a visitor's session" do
  # Cookie attribute names are case-insensitive, and Rack writes them lowercase.
  def set_cookie = Array(last_response.headers["set-cookie"]).join("\n").downcase

  def build_stack = Rack::Builder.parse_file(File.join(APP_ROOT, "config.ru"))

  it "hands a first-time visitor a session cookie" do
    get "/"

    expect(set_cookie).to include("weft_site_session=")
  end

  # The cookie carries the visitor's id and nothing else, but it is the only
  # thing standing between a visitor and someone else's data.
  it "keeps that cookie away from scripts and other sites" do
    get "/"

    expect(set_cookie).to include("httponly")
    expect(set_cookie).to include("samesite=lax")
  end

  it "refuses to assemble a stack with no session secret" do
    secret = ENV.delete("SESSION_SECRET")

    expect { build_stack }.to raise_error(KeyError, /SESSION_SECRET/)
  ensure
    ENV["SESSION_SECRET"] = secret
  end
end
