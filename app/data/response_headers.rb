# frozen_string_literal: true

module SiteData
  # Rack middleware, used first in config.ru so it wraps every response, the 403s
  # refused in front of the session included. Tells the browser where it may load
  # from, to stay on https, what to tell other sites, and how long to keep each
  # response. The reasoning in full: docs/development.md.
  class ResponseHeaders
    # Only what the pages load. Weft 0.2's one inline <script> (htmx's config)
    # takes no nonce, so it is allowed by hash, checked by a spec over every page.
    # No 'unsafe-eval': htmx wants it only for trigger filters and hx-on, and with
    # it, injected markup becomes script.
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

    # All private: every response renews the session cookie, which a shared cache
    # would hand to the next visitor. None long: no URL carries a version, so a
    # swapped file waits for the old copy to expire (then a cheap 304 on
    # Last-Modified). Fingerprinted URLs are what would justify a year, immutable.
    CACHE_CONTROL = {
      "/static/fonts/" => "private, max-age=604800", # a week
      "/static/js/" => "private, max-age=86400" # a day: a pin move changes htmx
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

    # Only a file that was found is kept: a 404 kept for a week outlives the fix.
    def cache_control(path, status)
      return REVALIDATE unless [200, 304].include?(status)

      CACHE_CONTROL.find { |prefix, _| path.start_with?(prefix) }&.last || REVALIDATE
    end
  end
end
