# frozen_string_literal: true

require_relative "config/environment"

require "rack/session"

# Weft ships no session handling, on purpose: identity is the application's to
# wire, out of ordinary Rack parts, in front of the Router. This is that wiring;
# docs/development.md covers what the secret is, why it has no fallback, and what
# a secure cookie needs from the proxy in front of it.
use Rack::Session::Cookie,
    key: "weft_site_session",
    secret: ENV.fetch("SESSION_SECRET"),
    expire_after: Store::TTL.to_i, # the id is worthless once its data has gone
    same_site: :lax,
    secure: ENV.fetch("RACK_ENV", "production") == "production",
    httponly: true

use VisitorScope

run Weft::Router
