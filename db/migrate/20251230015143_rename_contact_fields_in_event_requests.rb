
class RenameContactFieldsInEventRequests < ActiveRecord::Migration[8.0]
  def change
    rename_column :event_requests, :name, :organizer_name
    rename_column :event_requests, :email, :organizer_email
    rename_column :event_requests, :phone, :organizer_phone
  end
end