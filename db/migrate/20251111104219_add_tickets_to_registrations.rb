class AddTicketsToRegistrations < ActiveRecord::Migration[7.0]
  def change
    add_column :registrations, :tickets, :integer
  end
end
