# frozen_string_literal: true

module EditRow
  class PersonRowEditor < Weft::Component
    builder_method :person_row_editor

    param :person_id
    param :name
    param :email
    derives(:person) do |p|
      PersonData.find(p.person_id)
    end

    transfers :save, to: PersonRow do |params|
      PersonData.update(params.person_id,
                        name: params.name,
                        email: params.email)
      nil
    end

    transfers :cancel, to: PersonRow,
                       method: :get

    def tag_name = "tr"

    # A form cannot wrap table cells, so it sits in the last one, and the fields
    # in the others join it through their form attribute.
    def build(attributes = {})
      super
      field_cell :name
      field_cell :email
      td do
        form(action: :save, id: save_form) do
          authenticity_token
          input type: "hidden", name: "person_id", value: params.person_id
          input type: "submit", value: "Save"
          button "Cancel", type: "button", action: :cancel
        end
      end
    end

    private

    def field_cell(key)
      td do
        input type: "text", name: key, value: params.person[key], form: save_form
      end
    end

    def save_form = "save-person-#{params.person_id}"
  end
end
