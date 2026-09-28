# frozen_string_literal: true

module SiteData
  # Rack middleware, used first in config.ru so it wraps every response, the
  # 403s refused in front of the session included. Adds what a browser should be
  # told about each one: where it may load things from, to stay on https, how
  # much to say to other sites, and how long to keep it. X-Frame-Options and
  # X-XSS-Protection are left to the Rack::Protection weft's router runs.
  class ResponseHeaders
    # Every source here is something a page actually loads. Weft 0.2 writes one
    # inline <script> of its own (htmx's responseHandling config) with no way to
    # give it a nonce, so it is allowed by its hash; a spec renders every page
    # and checks each inline script against this list. No 'unsafe-eval': htmx
    # would need it for trigger filters and hx-on, and with it, any injected
    # markup becomes script.
    CONTENT_SECURITY_POLICY = [
      "default-src 'none'",
      "script-src 'self' 'sha256-thcqbt0TDLqzGDbsIMcZ6vA04lFE20xPPAHu3hb3WQ8='",
      "style-src 'self' 'unsafe-inline'", # htmx injects its indicator styles; weft's examples use style attributes
      "font-src 'self'",
      "img-src 'self'",
      "connect-src 'self'", # htmx's requests, and server-sent events
      "form-action 'self'",
      "base-uri 'none'",
      "frame-ancestors 'self'" # what X-Frame-Options: SAMEORIGIN says, for browsers that read only this
    ].join("; ")

    # Every response renews the session cookie, static files included, so none
    # may sit in a shared cache: it would hand one visitor's cookie to the next.
    CACHE_CONTROL = {
      "/static/fonts/" => "private, max-age=31536000, immutable",
      "/static/js/" => "private, max-age=86400" # htmx's URL carries no version, and a pin move changes it
    }.freeze
    REVALIDATE = "private, no-cache" # pages carry per-visitor state and the session's CSRF token

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      headers["content-security-policy"] = CONTENT_SECURITY_POLICY
      headers["strict-transport-security"] = "max-age=31536000" # no includeSubDomains: this host only
      headers["referrer-policy"] = "strict-origin-when-cross-origin" # other sites learn the origin, not the page
      headers["x-content-type-options"] ||= "nosniff" # weft sets it, but not on the 403s in front of it
      headers["cache-control"] ||= cache_control(env["PATH_INFO"], status)
      [status, headers, body]
    end

    private

    # Only a file that was found is kept: a 404 kept for a year outlives the fix.
    def cache_control(path, status)
      return REVALIDATE unless [200, 304].include?(status)

      CACHE_CONTROL.find { |prefix, _| path.start_with?(prefix) }&.last || REVALIDATE
    end
  end
end
