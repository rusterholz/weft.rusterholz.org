# frozen_string_literal: true

module DeleteRow
  # Stands in for a data layer, the way the gem's own docs use a constant. Here it
  # is the visitor's own copy, which expires; the verbs are the same either way.
  class ContactData
    SEED = {
      "1" => { name: "Angie MacDowell", email: "angie@macdowell.org", status: "Active" },
      "2" => { name: "Fuqua Tarkenton", email: "fuqua@tarkenton.org", status: "Active" },
      "3" => { name: "Kim Yee", email: "kim@yee.org", status: "Inactive" }
    }.freeze

    class << self
      def all = store.fetch

      def find(id) = contact(all, id)

      def reset! = store.reset!

      def delete(id)
        store.update do |contacts|
          contact(contacts, id) # not found, rather than a quiet nothing
          contacts.delete(id)
        end
      end

      private

      def store = SiteData::Store.for("delete_row", seed: SEED)

      def contact(contacts, id)
        contacts.fetch(id) { raise Weft::NotFound, "No contact #{id.inspect}" }
      end
    end
  end
end
