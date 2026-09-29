# frozen_string_literal: true

module DeleteRow
  class ContactRow < Weft::Component
    builder_method :contact_row

    # The table hands each row its own contact; the wire carries it back when
    # the row's Delete button is clicked.
    param :contact_id
    receives :contact_id
    derives(:contact) do |p|
      ContactData.find(p.contact_id)
    end

    dismisses :destroy do |params|
      ContactData.delete(params.contact_id)
      nil
    end

    def tag_name = "tr"

    def build(attributes = {})
      super
      td params.contact[:name]
      td params.contact[:email]
      td params.contact[:status]
      td do
        button "Delete", action: :destroy, confirm: "Are you sure?"
      end
    end
  end
end
