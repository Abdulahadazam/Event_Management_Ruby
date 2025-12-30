
class AddEventRequestReferenceToEvents < ActiveRecord::Migration[8.0]
  def change
    add_reference :events, :event_request, foreign_key: true
  end
end