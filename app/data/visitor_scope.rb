# frozen_string_literal: true

require "rack/request"
require "securerandom"

# Gives every visitor an opaque id and publishes it on Current for one request.
# That id is the whole of this site's identity, and it is what namespaces a
# visitor's copy of an example's data in the Store. It lives in the session,
# which is an encrypted cookie (see config.ru), so a visitor can neither read
# their own id nor forge anyone else's: hence the session middleware ahead.
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
    @app.call(env)
  ensure
    # Threads are reused: state left here is state the next visitor reads.
    Current.reset
  end
end
