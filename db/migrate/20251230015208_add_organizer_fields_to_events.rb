
class AddOrganizerFieldsToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :organizer_name, :string
    add_column :events, :organizer_email, :string
    add_column :events, :organizer_phone, :string
  end
end