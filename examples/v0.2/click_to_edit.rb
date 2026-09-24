# frozen_string_literal: true

module ClickToEdit
  SEED = {
    "1" => { first_name: "Joe", last_name: "Blow", email: "joe@blow.com" }
  }.freeze

  # Stands in for a data layer, the way the gem's own docs use a constant. Here
  # it is the visitor's own copy, which expires; the verbs are the same either way.
  class Contacts
    class << self
      def all = store.fetch

      def find(id) = all[id] || raise(Weft::NotFound, "No contact #{id.inspect}")

      def update(id, **attributes)
        store.update { |contacts| contacts.fetch(id).merge!(attributes) }
      end

      private

      def store = Store.for("click_to_edit", seed: SEED)
    end
  end

  class ContactCard < Weft::Component
    builder_method :contact_card

    # Two doors for one value: the page hands the contact over when it renders
    # the card, and the wire carries it when htmx fetches the card on its own.
    param :contact_id
    receives :contact_id

    def build(attributes = {})
      super
      field "First Name", :first_name
      field "Last Name", :last_name
      field "Email", :email
      button "Click To Edit",
             loads: ContactEditor, with: { contact_id: params.contact_id },
             swap: :replace, target: self
    end

    private

    def contact = @contact ||= Contacts.find(params.contact_id)

    def field(label_text, key)
      div do
        strong "#{label_text}: "
        text_node contact[key]
      end
    end
  end

  class ContactEditor < Weft::Component
    builder_method :contact_editor

    param :contact_id
    param :first_name
    param :last_name
    param :email

    transfers :save, to: ContactCard do |params|
      Contacts.update(params.contact_id,
                      first_name: params.first_name, last_name: params.last_name, email: params.email)
      nil
    end

    def build(attributes = {})
      super
      form(action: :save) do
        input(type: "hidden", name: "contact_id", value: params.contact_id)
        text_field "First Name", :first_name
        text_field "Last Name", :last_name
        text_field "Email", :email
        input(type: "submit", value: "Submit")
        button "Cancel",
               type: "button",
               loads: ContactCard, with: { contact_id: params.contact_id },
               swap: :replace, target: self
      end
    end

    private

    def contact = @contact ||= Contacts.find(params.contact_id)

    def text_field(label_text, key)
      div do
        label("#{label_text} ", for: key)
        input(type: "text", name: key, id: key, value: contact[key])
      end
    end
  end
end
