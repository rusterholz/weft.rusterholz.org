# frozen_string_literal: true

# The one prominent note an article can carry: a name weft changes later, or a
# rough edge an adopter will meet. Tint tone on a copper rule, the grammar of the
# highlighted declaration in the margin. It classifies nothing; the page's words do.
class Callout < Weft::Component
  builder_method :callout

  # Weft would give every callout the one id its class name yields.
  def weft_dom_id = nil

  def build(attributes = {})
    super(attributes.merge(class: "callout", role: "note"))
  end
end
