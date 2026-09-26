# frozen_string_literal: true

module ClickToEdit
  # Stands in for a data layer, the way the gem's own docs use a constant. Here it
  # is the visitor's own copy, which expires; the verbs are the same either way.
  class Contacts
    SEED = {
      "1" => { first_name: "Joe", last_name: "Blow", email: "joe@blow.com" }
    }.freeze

    class << self
      def all = store.fetch

      def find(id) = contact(all, id)

      def reset! = store.reset!

      # A form that leaves a field out means "unchanged" rather than "blank",
      # which is compact's job. Hash#slice guards nothing a visitor can reach,
      # since a callable only ever sees declared params: it is there for the next
      # data class copied from this one, whose caller may be less careful.
      def update(id, **attributes)
        store.update do |contacts|
          held = contact(contacts, id)
          held.merge!(attributes.compact.slice(*held.keys))
        end
      end

      private

      def store = Store.for("click_to_edit", seed: SEED)

      # Reading and writing a contact nobody has are the same question, and get
      # the same answer: Weft renders its not-found page or fragment.
      def contact(contacts, id)
        contacts.fetch(id) { raise Weft::NotFound, "No contact #{id.inspect}" }
      end
    end
  end
end
