# frozen_string_literal: true

module UpdatingOtherContent
  class NewContactForm < Weft::Component
    builder_method :new_contact_form

    param :name
    param :email

    # Every response this form gives carries the table too, out of band.
    includes ContactsTable

    performs :add do |params|
      ContactData.create(name: params.name, email: params.email)
      { name: nil, email: nil }
    end

    def build(attributes = {})
      super
      h3 "Add a Contact"
      form(action: :add) do
        authenticity_token
        label "Name ", for: "name"
        input type: "text", name: "name", id: "name"
        label " Email ", for: "email"
        input type: "email", name: "email", id: "email"
        input type: "submit", value: "Add Contact"
      end
    end
  end
end
