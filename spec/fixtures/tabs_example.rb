# frozen_string_literal: true

# A running example made in a spec: one whose files call none of the site's own
# components. Loaded, and taken away again, by the spec that uses it.
module Tabs
  class Panes
    def self.all = %w[One Two]
  end

  class TabStrip < Weft::Component
    builder_method :spec_tab_strip

    def build(attributes = {})
      super
      Panes.all.each { |pane| span pane }
    end
  end
end

class TabsPage < ExamplePage
  describes panes: "the panes", tab_strip: "the strip over them", tabs_page: "a page to put it on"

  def walkthrough
    live { spec_tab_strip }
  end
end
