class AddTicketTypesToEventRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :event_requests, :has_multiple_ticket_types, :boolean, default: false, null: false
    add_column :event_requests, :ticket_types_data, :jsonb, default: {}
  end
end
