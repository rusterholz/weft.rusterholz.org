# frozen_string_literal: true

module ResetUserInput
  # Stands in for your app's model: list the comments, then create one, as an
  # ORM model would. Here each visitor has their own copy, and it expires.
  class CommentData < SiteData::Records
    SEED = {
      "1" => { author: "Rosa", body: "Lovely event, and count me in for next year." }
    }.freeze

    stored_in "reset_user_input", seed: SEED
  end
end
