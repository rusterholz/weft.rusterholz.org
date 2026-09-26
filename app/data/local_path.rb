# frozen_string_literal: true

# A path on this site, from a value a request carried: anything else, such as
# another host or a protocol-relative "//", becomes the home page. Every redirect
# to an address the browser supplied goes through here.
module LocalPath
  class << self
    def or_home(path)
      path = path.to_s
      path.match?(%r{\A/(?![/\\])}) ? path : "/"
    end
  end
end
