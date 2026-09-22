# frozen_string_literal: true

# The branded error page is only reachable through a render that fails, and
# nothing in the site fails on purpose. This is that failure, exercised through
# the gem's real recovery chain. Loaded only by spec_helper, never by the site.
class ExplodingPage < ApplicationPage
  self.page_path = "/_spec/explode"

  BANG = "deliberate failure raised by a spec"

  def build(attributes = {})
    super
    raise BANG
  end
end
