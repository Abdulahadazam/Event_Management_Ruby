class AddCoordinatesToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :lonlat, :st_point, geographic: true
    
    add_index :events, :lonlat, using: :gist
    
    add_column :events, :latitude, :decimal, precision: 10, scale: 6
    add_column :events, :longitude, :decimal, precision: 10, scale: 6
  end
end