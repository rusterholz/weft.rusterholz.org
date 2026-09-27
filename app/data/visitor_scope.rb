# frozen_string_literal: true

require "rack/protection"
require "rack/request"
require "securerandom"

# Rack middleware, used in config.ru right after the session cookie middleware.
# Gives every visitor an opaque id and publishes it on Current for one request.
# That id is the whole of this site's identity, and it is what namespaces a
# visitor's copy of an example's data in the Store. It lives in the session, an
# encrypted cookie, so a visitor can neither read their own id nor forge anyone
# else's. It also publishes the session's CSRF token, for every form that writes
# to carry.
class VisitorScope
  SESSION_KEY = "visitor"

  NoSession = Class.new(StandardError)

  def initialize(app)
    @app = app
  end

  def call(env)
    session = env["rack.session"]
    raise NoSession, "VisitorScope needs a session middleware ahead of it in config.ru" unless session

    Current.visitor = (session[SESSION_KEY] ||= SecureRandom.hex(16))
    Current.request = Rack::Request.new(env)
    Current.csrf_token = Rack::Protection::AuthenticityToken.token(session)
    @app.call(env)
  ensure
    # Threads are reused: state left here is state the next visitor reads.
    Current.reset
  end
end
