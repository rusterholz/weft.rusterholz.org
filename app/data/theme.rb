# frozen_string_literal: true

# The visitor's chosen theme, kept in their session. No choice is an answer too:
# the page then follows the system's light or dark setting, which only the
# browser knows. It lapses with the session, along with everything else.
module Theme
  SESSION_KEY = "theme"
  CHOICES = %w[light dark].freeze

  class << self
    def current
      chosen = Current.request&.session&.[](SESSION_KEY)
      chosen if CHOICES.include?(chosen)
    end

    def choose(theme)
      Current.request.session[SESSION_KEY] = theme if CHOICES.include?(theme)
    end
  end
end
