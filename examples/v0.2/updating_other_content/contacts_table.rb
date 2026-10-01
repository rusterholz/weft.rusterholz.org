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
          ContactData.all.each { |contact| contact_row(contact) }
        end
      end
    end

    private

    def contact_row(contact)
      tr do
        td contact[:name]
        td contact[:email]
      end
    end
  end
end
