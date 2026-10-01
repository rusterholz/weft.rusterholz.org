# frozen_string_literal: true

module BulkUpdate
  class MemberRoster < Weft::Component
    builder_method :member_roster

    # Every ticked box arrives under active_ids[], folded into one array. With
    # none ticked the browser sends nothing, and the default means "nobody".
    param :active_ids, default: []
    param :status

    performs :update do |params|
      activated = 0
      deactivated = 0
      MemberData.all.each do |member|
        active = params.active_ids.include?(member.id)
        activated += 1 if active && !member[:active]
        deactivated += 1 if !active && member[:active]
        member.update(active: active)
      end
      { status: "Activated #{activated} and deactivated #{deactivated} members." }
    end

    def build(attributes = {})
      super
      form(action: :update) do
        authenticity_token
        member_table
        input type: "submit", value: "Bulk Update"
      end
      para params.status if params.status
    end

    private

    def member_table
      table do
        thead do
          tr do
            th "Name"
            th "Email"
            th "Active"
          end
        end
        tbody do
          MemberData.all.each { |member| member_row(member) }
        end
      end
    end

    def member_row(member)
      tr do
        td member[:name]
        td member[:email]
        td do
          if member[:active]
            input type: "checkbox", name: "active_ids[]", value: member.id, checked: "checked"
          else
            input type: "checkbox", name: "active_ids[]", value: member.id
          end
        end
      end
    end
  end
end
