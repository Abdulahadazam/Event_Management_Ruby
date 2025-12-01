class Category < ApplicationRecord
  has_many :events
  validates :name, presence: true
   has_many :event_requests  

  def self.ransackable_attributes(auth_object = nil)
    %w[id name slug created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[events event_requests]
  end


end
