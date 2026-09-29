# frozen_string_literal: true

module EditRow
  # Stands in for a data layer, the way the gem's own docs use a constant. Here it
  # is the visitor's own copy, which expires; the verbs are the same either way.
  class PersonData
    SEED = {
      "1" => { name: "Joe Smith", email: "joe@smith.org" },
      "2" => { name: "Angie MacDowell", email: "angie@macdowell.org" },
      "3" => { name: "Fuqua Tarkenton", email: "fuqua@tarkenton.org" }
    }.freeze

    class << self
      def all = store.fetch

      def find(id) = person(all, id)

      def reset! = store.reset!

      # A field left out means "unchanged", and only a person's own fields change.
      def update(id, **attributes)
        store.update do |people|
          held = person(people, id)
          held.merge!(attributes.compact.slice(*held.keys))
        end
      end

      private

      def store = SiteData::Store.for("edit_row", seed: SEED)

      def person(people, id)
        people.fetch(id) { raise Weft::NotFound, "No person #{id.inspect}" }
      end
    end
  end
end
