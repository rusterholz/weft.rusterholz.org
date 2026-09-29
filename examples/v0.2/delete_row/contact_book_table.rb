# frozen_string_literal: true

module DeleteRow
  class ContactBookTable < Weft::Component
    builder_method :contact_book_table

    def build(attributes = {})
      super
      table do
        thead do
          tr do
            th "Name"
            th "Email"
            th "Status"
            th ""
          end
        end
        tbody do
          ContactData.all.each_key { |id| contact_row contact_id: id }
        end
      end
    end
  end
end
