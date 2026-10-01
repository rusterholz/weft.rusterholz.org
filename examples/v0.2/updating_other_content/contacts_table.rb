# frozen_string_literal: true

module UpdatingOtherContent
  class ContactsTable < Weft::Component
    builder_method :contacts_table

    def build(attributes = {})
      super
      table do
        thead do
          tr do
            th "Name"
            th "Email"
          end
        end
        tbody do
          ContactData.all.each { |contact| row_for(contact) }
        end
      end
    end

    private

    def row_for(contact)
      tr do
        td contact[:name]
        td contact[:email]
      end
    end
  end
end
