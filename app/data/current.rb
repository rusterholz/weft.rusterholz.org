# frozen_string_literal: true

require "active_support/current_attributes"

# Per-request state that Weft's params channel deliberately does not carry:
# components and callables receive only their declared params, so identity has
# to travel beside them, and so does the CSRF token every writing form carries.
# VisitorScope fills them all and clears them.
class Current < ActiveSupport::CurrentAttributes
  attribute :visitor, :request, :csrf_token
end
