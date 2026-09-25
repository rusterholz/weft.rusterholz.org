# frozen_string_literal: true

module ClickToEdit
  class ContactCard < Weft::Component
    builder_method :contact_card

    # Two doors for one value: the page hands the contact over when it renders
    # the card, and the wire carries it when htmx fetches the card on its own.
    param :contact_id
    receives :contact_id
    derives(:contact) { |p| Contacts.find(p.contact_id) }

    transfers :edit, to: ContactEditor, method: :get

    def build(attributes = {})
      super
      field "First Name", :first_name
      field "Last Name", :last_name
      field "Email", :email
      button "Click To Edit", action: :edit
    end

    private

    def field(label_text, key)
      div do
        strong "#{label_text}: "
        text_node params.contact[key]
      end
    end
  end
end
