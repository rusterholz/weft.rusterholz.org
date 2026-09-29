# frozen_string_literal: true

module DeleteRow
  # Stands in for your app's model: find a contact, then destroy it, as an ORM
  # model would. Here each visitor has their own copy, and it expires.
  class ContactData < SiteData::Records
    SEED = {
      "1" => { name: "Angie MacDowell", email: "angie@macdowell.org", status: "Active" },
      "2" => { name: "Fuqua Tarkenton", email: "fuqua@tarkenton.org", status: "Active" },
      "3" => { name: "Kim Yee", email: "kim@yee.org", status: "Inactive" }
    }.freeze

    stored_in "delete_row", seed: SEED
  end
end
