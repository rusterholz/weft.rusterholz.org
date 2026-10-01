# frozen_string_literal: true

module BulkUpdate
  # Stands in for your app's model: list the members, then update each, as an
  # ORM model would. Here each visitor has their own copy, and it expires.
  class MemberData < SiteData::Records
    SEED = {
      "1" => { name: "Joe Smith", email: "joe@smith.org", active: true },
      "2" => { name: "Angie MacDowell", email: "angie@macdowell.org", active: true },
      "3" => { name: "Fuqua Tarkenton", email: "fuqua@tarkenton.org", active: true },
      "4" => { name: "Kim Yee", email: "kim@yee.org", active: false }
    }.freeze

    stored_in "bulk_update", seed: SEED
  end
end
