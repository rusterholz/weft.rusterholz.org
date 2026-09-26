# frozen_string_literal: true

require "active_support/core_ext/string/output_safety"

# The header's theme switch: one instance per theme it offers, each a form
# holding one button. The header renders both, and the stylesheet shows the one
# that changes something, which depends on the system setting only the browser
# can see. Choosing stores the theme in the session and reloads the page it was
# chosen on, since the theme is an attribute of the whole document.
class ThemeToggle < Weft::Component
  builder_method :theme_toggle

  ICONS = {
    "dark" => '<path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"></path>',
    "light" => '<circle cx="12" cy="12" r="4"></circle><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 ' \
               '1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"></path>'
  }.freeze

  param :theme
  receives :theme
  param :return_to
  receives :return_to
  derives(:icon) do |p|
    ICONS.fetch(p.theme) { raise Weft::NotFound, "No theme #{p.theme.inspect}" }
  end

  performs :choose do |params|
    Theme.choose(params.theme)
    Weft.redirect(LocalPath.or_home(params.return_to))
  end

  def build(attributes = {})
    super
    form(action: :choose) do
      input type: "hidden", name: "theme", value: params.theme
      input type: "hidden", name: "return_to", value: params.return_to
      button(type: "submit", class: "flat icon", "aria-label": "Switch to #{params.theme} theme") { icon }
    end
  end

  private

  def icon
    text_node '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" ' \
              "stroke-width=\"2\" aria-hidden=\"true\">#{params.icon}</svg>".html_safe
  end
end
