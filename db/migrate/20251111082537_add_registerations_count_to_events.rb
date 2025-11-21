class AddRegisterationsCountToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :registrations_count, :integer, default: 0, null: false

  end
end
