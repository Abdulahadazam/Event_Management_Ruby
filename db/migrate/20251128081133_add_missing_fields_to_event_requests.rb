class AddMissingFieldsToEventRequests < ActiveRecord::Migration[7.0]
  def change
    
    add_column :event_requests, :preferred_date, :date unless column_exists?(:event_requests, :preferred_date)
    add_column :event_requests, :preferred_time, :time unless column_exists?(:event_requests, :preferred_time)
    add_column :event_requests, :platform, :string unless column_exists?(:event_requests, :platform)
    add_column :event_requests, :city, :string unless column_exists?(:event_requests, :city)
    add_column :event_requests, :country, :string unless column_exists?(:event_requests, :country)
    add_column :event_requests, :venue_address, :string unless column_exists?(:event_requests, :venue_address)
    add_column :event_requests, :meeting_link, :string unless column_exists?(:event_requests, :meeting_link)
    add_column :event_requests, :is_remote, :boolean, default: false unless column_exists?(:event_requests, :is_remote)
    add_column :event_requests, :notes, :text unless column_exists?(:event_requests, :notes)
    add_column :event_requests, :time_zone, :string unless column_exists?(:event_requests, :time_zone)
    add_column :event_requests, :status, :integer, default: 0 unless column_exists?(:event_requests, :status)
  end
end
