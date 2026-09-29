# frozen_string_literal: true

module EditRow
  class PeopleTable < Weft::Component
    builder_method :people_table

    def build(attributes = {})
      super
      table do
        thead do
          tr do
            th "Name"
            th "Email"
            th ""
          end
        end
        tbody do
          PersonData.all.each { |person| person_row person_id: person.id }
        end
      end
    end
  end
end
