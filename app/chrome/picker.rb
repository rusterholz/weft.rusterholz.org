# frozen_string_literal: true

# A dropdown over any collection of destinations, each a label and a path. With
# fewer than two it is disabled, with a tooltip saying why. Subclasses supply the
# collection (VersionPicker), so a call site never has to know where the list
# comes from.
#
# Choosing navigates: htmx sends the form on change and weft answers with a
# redirect, and without htmx the button inside <noscript> sends it instead.
class Picker < Weft::Component
  builder_method :picker
  abstract! # a subclass has the list; on its own there is nothing to serve

  receives :options
  receives :current
  receives :label
  receives :disabled_reason

  param :to

  performs :go, method: :get do |params|
    Weft.redirect(LocalPath.or_home(params.to))
  end

  def build(attributes = {})
    super(attributes.merge(class: "picker-host"))
    params.options.size < 2 ? disabled : live
  end

  private

  # A disabled control swallows the pointer, so the reason goes on its wrapper.
  def disabled
    span class: "picker", title: params.disabled_reason do
      select(disabled: true, "aria-label": params.label) { entries }
    end
  end

  def live
    form(action: :go, trigger: :change, class: "picker") do
      select(name: "to", "aria-label": params.label) { entries }
      noscript { button "Go", type: "submit", class: "flat" }
    end
  end

  def entries
    params.options.each do |text, path|
      option text, value: path, selected: text == params.current || nil
    end
  end
end
