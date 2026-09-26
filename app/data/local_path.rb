# frozen_string_literal: true

# A path on this site, from a value a request carried; anything else is home.
# The whole string is checked: a line break in a header lets Puma split off a
# redirect of its own, and browsers read a backslash as a slash.
module LocalPath
  SAFE = %r{\A/(?![/\\])[^\x00-\x20\x7f\\]*\z}

  class << self
    def or_home(path)
      path = path.to_s
      path.match?(SAFE) ? path : "/"
    end
  end
end
