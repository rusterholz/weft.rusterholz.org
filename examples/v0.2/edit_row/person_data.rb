# frozen_string_literal: true

module EditRow
  # Stands in for your app's model: find a person, then update them, as an ORM
  # model would. Here each visitor has their own copy, and it expires.
  class PersonData < SiteData::Records
    SEED = {
      "1" => { name: "Joe Smith", email: "joe@smith.org" },
      "2" => { name: "Angie MacDowell", email: "angie@macdowell.org" },
      "3" => { name: "Fuqua Tarkenton", email: "fuqua@tarkenton.org" }
    }.freeze

    stored_in "edit_row", seed: SEED
  end
end
