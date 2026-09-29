# frozen_string_literal: true

module EditRow
  class PersonRow < Weft::Component
    builder_method :person_row

    # The table hands each row its own person; the wire carries it when the row
    # renders in answer to a request.
    param :person_id
    receives :person_id
    derives(:person) do |p|
      PersonData.find(p.person_id)
    end

    transfers :edit, to: PersonRowEditor,
                     method: :get

    def tag_name = "tr"

    def build(attributes = {})
      super
      td params.person[:name]
      td params.person[:email]
      td do
        button "Edit", action: :edit
      end
    end
  end
end
