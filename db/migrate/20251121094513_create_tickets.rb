class CreateTickets < ActiveRecord::Migration[7.0]
  def change
    create_table :tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.references :registration, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :total_amount
      t.string :status
      t.string :payment_method
      t.string :payment_id

      t.timestamps
    end
  end
end
