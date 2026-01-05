class AddEventRequestFieldsToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :is_remote, :boolean, default: false
    add_column :events, :venue_address, :string
    add_column :events, :city, :string
    add_column :events, :country, :string
    add_column :events, :platform, :string
    add_column :events, :meeting_link, :string
    add_column :events, :time_zone, :string
    add_column :events, :preferred_time, :string
    add_column :events, :event_capacity, :integer
    add_column :events, :has_multiple_ticket_types, :boolean, default: false, null: false
    add_column :events, :ticket_types_data, :jsonb, default: {}
    add_column :events, :notes, :text
  end
end
