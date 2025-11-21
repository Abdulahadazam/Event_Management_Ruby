class AddCategoryRefToEvents < ActiveRecord::Migration[7.0]
  def change
    add_reference :events, :category, foreign_key: true
  end
end
