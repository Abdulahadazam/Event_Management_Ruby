class ChangeRoleToIntegerInUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :role_temp, :integer, default: 0, null: false

    execute <<~SQL
      UPDATE users SET role_temp = 0 WHERE role = 'attendee';
      UPDATE users SET role_temp = 1 WHERE role = 'organizer';
    SQL

    remove_column :users, :role
    rename_column :users, :role_temp, :role
  end

  def down
    add_column :users, :role_temp, :string, default: 'attendee', null: false

    execute <<~SQL
      UPDATE users SET role_temp = 'attendee' WHERE role = 0;
      UPDATE users SET role_temp = 'organizer' WHERE role = 1;
    SQL

    remove_column :users, :role
    rename_column :users, :role_temp, :role
  end
end
