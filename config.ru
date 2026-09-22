# frozen_string_literal: true

require_relative "config/environment"

# The session cookie and the middleware that scopes a visitor's stored data
# arrive with the store seam; until then the Router is the whole stack.
run Weft::Router
