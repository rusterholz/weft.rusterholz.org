# frozen_string_literal: true

# A path on this site, from a value a request carried; anything else is home.
# Printable ASCII only (real paths arrive percent-encoded): a line break lets Puma
# split off a redirect of its own, and browsers read a backslash as a slash.
module LocalPath
  SAFE = %r{\A/(?![/\\])[\x21-\x5b\x5d-\x7e]*\z}

  class << self
    def or_home(path)
      path = path.to_s
      path.valid_encoding? && path.match?(SAFE) ? path : "/"
    end
  end
end
