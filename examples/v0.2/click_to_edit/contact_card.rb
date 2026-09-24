# frozen_string_literal: true

module ClickToEdit
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
end
