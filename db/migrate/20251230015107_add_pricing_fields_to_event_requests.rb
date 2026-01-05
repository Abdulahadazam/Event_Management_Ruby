
class AddPricingFieldsToEventRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :event_requests, :ticket_price, :decimal, precision: 10, scale: 2, default: 0.0, null: false
    add_column :event_requests, :event_capacity, :integer
  end
end