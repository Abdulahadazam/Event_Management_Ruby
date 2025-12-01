class Event < ApplicationRecord
  belongs_to :category, optional: true
  has_many :registrations, dependent: :destroy
  has_many :attendees, through: :registrations, source: :user

  has_one_attached :banner
   
  def banner_url
    return nil unless banner.attached?
    Rails.application.routes.url_helpers.rails_blob_path(banner, only_path: true)
  rescue ActiveRecord::InverseOfAssociationNotFoundError
    nil
  end
  def self.ransackable_attributes(auth_object = nil)
    %w[id title description date location created_at updated_at category_id price]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[registrations category]
  end

  def attendees_count
    registrations.sum(:tickets)
  end

  def registered?(user)
    return false unless user
    registrations.exists?(user_id: user.id)
  end
end
