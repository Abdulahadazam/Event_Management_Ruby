class AddTicketTypeToTickets < ActiveRecord::Migration[8.0]
  def change
    add_column :tickets, :ticket_type, :string
  end
end
