class FixCategoryReferenceInEventRequests < ActiveRecord::Migration[8.0]
  def change
    remove_column :event_requests, :event_category_id, :integer
    
    add_reference :event_requests, :category, foreign_key: true
  end
end