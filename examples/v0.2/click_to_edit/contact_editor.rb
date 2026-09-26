# frozen_string_literal: true

module ClickToEdit
  class ContactEditor < Weft::Component
    builder_method :contact_editor

    param :contact_id
    param :first_name
    param :last_name
    param :email
    derives(:contact) do |p|
      Contacts.find(p.contact_id)
    end

    transfers :save, to: ContactCard do |params|
      Contacts.update(params.contact_id,
                      first_name: params.first_name,
                      last_name: params.last_name,
                      email: params.email)
      nil
    end

    transfers :cancel, to: ContactCard,
                       method: :get

    def build(attributes = {})
      super
      form(action: :save) do
        input(type: "hidden", name: "contact_id", value: params.contact_id)
        text_field "First Name", :first_name
        text_field "Last Name", :last_name
        text_field "Email", :email
        input(type: "submit", value: "Save")
        button "Cancel", type: "button", action: :cancel
      end
    end

    private

    def text_field(label_text, key)
      div do
        label("#{label_text} ", for: key)
        input(type: "text", name: key, id: key, value: params.contact[key])
      end
    end
  end
end
