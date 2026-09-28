# frozen_string_literal: true

# A running example made in a spec, whose component calls a site component that
# describes nothing: Callout. Loaded, and taken away again, by the spec that uses it.
module Tabs
  class TabStrip < Weft::Component
    builder_method :spec_tab_strip

    def build(attributes = {})
      super
      callout { span "One" }
    end
  end
end

class TabsPage < ExamplePage
  describes tab_strip: "the strip", tabs_page: "a page to put it on"

  def walkthrough
    live { spec_tab_strip }
  end
end
