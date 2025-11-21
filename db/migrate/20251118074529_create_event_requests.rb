class CreateEventRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :event_requests do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :event_title
      t.text :event_description
      t.date :preferred_date
      t.string :preferred_time
      t.boolean :is_remote
      t.string :venue_address
      t.string :city
      t.string :country
      t.string :platform
      t.string :meeting_link
      t.string :time_zone
      t.integer :event_category_id
      t.integer :status
      t.text :notes

      t.timestamps
    end
  end
end
