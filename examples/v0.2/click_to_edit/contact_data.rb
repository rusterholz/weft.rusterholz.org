# frozen_string_literal: true

module ClickToEdit
  # Stands in for your app's model: find a contact, then update it, as an ORM
  # model would. Here each visitor has their own copy, and it expires.
  class ContactData < SiteData::Records
    SEED = {
      "1" => { first_name: "Joe", last_name: "Blow", email: "joe@blow.com" }
    }.freeze

    stored_in "click_to_edit", seed: SEED
  end
end
