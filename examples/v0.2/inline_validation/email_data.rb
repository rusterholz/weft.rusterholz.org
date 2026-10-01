# frozen_string_literal: true

module InlineValidation
  # Stands in for the uniqueness check your app's data layer would run.
  class EmailData
    TAKEN = ["taken@example.com"].freeze

    def self.taken?(email) = TAKEN.include?(email)
  end
end
