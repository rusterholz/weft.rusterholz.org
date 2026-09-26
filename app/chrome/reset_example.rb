# frozen_string_literal: true

# "Reset This Example": puts the visitor's copy of an example's data back as it
# started, then reloads the example. A form, so it works with or without htmx.
class ResetExample < Weft::Component
  builder_method :reset_example

  param :slug
  receives :slug

  performs :reset do |params|
    Weft.redirect(ExamplePage.reset!(params.slug))
  end

  def build(attributes = {})
    super(attributes.merge(class: "reset-example"))
    form(action: :reset) do
      authenticity_token
      input type: "hidden", name: "slug", value: params.slug
      button "Reset This Example", type: "submit", class: "flat"
    end
  end
end
