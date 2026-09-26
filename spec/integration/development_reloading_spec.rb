# frozen_string_literal: true

require "open3"

# bin/dev reloads the code on every request, and the suite never does, so two
# kinds of break show up only in a running development server: a stale class
# left on the route table (every request after the first collides) and a store
# reloaded away (every request is a first visit). This boots one to watch for both.
RSpec.describe "serving in development, where every request reloads the code" do
  # localhost, because Sinatra's development host protection refuses rack-test's example.org.
  let(:script) do
    <<~RUBY
      ENV["RACK_ENV"] = "development"
      ENV["SESSION_SECRET"] = "x" * 64
      require "bundler/setup"
      require "rack/builder"
      require "rack/test"

      browser = Rack::Test::Session.new(Rack::Builder.parse_file("config.ru"), "localhost")
      seen = []
      browser.get "/examples/click-to-edit"
      seen << browser.last_response.status
      token = browser.last_response.body[/name="authenticity_token" value="([^"]+)"/, 1]
      browser.post "/_components/click_to_edit/contact_editor/save",
                   contact_id: "1", first_name: "Joseph", authenticity_token: token
      seen << browser.last_response.status
      browser.get "/_components/click_to_edit/contact_card", contact_id: "1"
      seen << browser.last_response.status << browser.last_response.body.include?("Joseph")
      puts "SEEN \#{seen.join(' ')}"
    RUBY
  end

  it "answers every request, and keeps a visitor's edit from one reload to the next" do
    output, status = Open3.capture2e("bundle", "exec", "ruby", "-e", script, chdir: APP_ROOT)

    expect(status).to be_success, output
    expect(output[/^SEEN (.*)$/, 1]).to eq("200 200 200 true"), output
  end
end
