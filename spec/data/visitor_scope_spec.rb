# frozen_string_literal: true

RSpec.describe VisitorScope do
  let(:session) { {} }
  let(:seen) { {} }

  # A real Rack app below the middleware, not a double: what this middleware
  # publishes to the app under it is the whole claim, so the app has to be the
  # thing that observes it.
  let(:downstream) do
    lambda do |_env|
      seen[:visitor] = Current.visitor
      seen[:request] = Current.request
      [200, {}, ["ok"]]
    end
  end

  def call(app = downstream, session: self.session)
    env = Rack::MockRequest.env_for("/")
    env["rack.session"] = session if session
    described_class.new(app).call(env)
  end

  it "mints a visitor id into the session on first sight" do
    call

    expect(session["visitor"]).to be_a(String)
    expect(session["visitor"]).not_to be_empty
    expect(seen[:visitor]).to eq(session["visitor"])
  end

  it "mints a different id for every visitor" do
    call
    first = session["visitor"]
    session.clear

    call

    expect(session["visitor"]).not_to eq(first)
  end

  it "reuses the id the session already carries" do
    session["visitor"] = "a-returning-visitor"

    call

    expect(seen[:visitor]).to eq("a-returning-visitor")
    expect(session["visitor"]).to eq("a-returning-visitor")
  end

  it "clears the visitor and the request once the request is over" do
    call

    expect(seen[:visitor]).not_to be_nil
    expect(seen[:request]).to be_a(Rack::Request)
    expect(Current.visitor).to be_nil
    expect(Current.request).to be_nil
  end

  it "clears them even when the request fails" do
    expect { call(->(_env) { raise "deliberate failure" }) }.to raise_error("deliberate failure")

    expect(Current.visitor).to be_nil
    expect(Current.request).to be_nil
  end

  it "says what is wrong when no session middleware ran ahead of it" do
    expect { call(session: nil) }.to raise_error(VisitorScope::NoSession, /session middleware/)
  end
end
