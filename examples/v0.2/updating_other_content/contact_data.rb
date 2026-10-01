# frozen_string_literal: true

module UpdatingOtherContent
  # Stands in for your app's model: list the contacts, then create one, as an
  # ORM model would. Here each visitor has their own copy, and it expires.
  class ContactData < SiteData::Records
    SEED = {
      "1" => { name: "Joe Smith", email: "joe@smith.org" }
    }.freeze

    stored_in "updating_other_content", seed: SEED
  end
end
