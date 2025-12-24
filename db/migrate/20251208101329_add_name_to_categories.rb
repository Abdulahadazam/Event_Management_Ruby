class AddNameToCategories < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:categories, :name)
      add_column :categories, :name, :string
      add_index :categories, :name, unique: true
    end
  end
end
