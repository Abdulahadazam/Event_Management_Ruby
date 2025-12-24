class Category < ApplicationRecord

  has_many :events
  has_many :event_requests  

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  
  def events_count
    events.count
  end
  
  def self.find_by_name(name)
    find_by("LOWER(name) = ?", name.downcase)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id name slug created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[events event_requests]
  end

end
