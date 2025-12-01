class EventRequest < ApplicationRecord
      enum :status, { pending: 0, approved: 1, rejected: 2 }, default: :pending


  belongs_to :category, class_name: "Category", optional: true 
  has_one_attached :banner

  validates :name, :email, :event_title, :event_description, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }


  
  def self.ransackable_associations(auth_object = nil)
    ["banner_attachment", "banner_blob", "category"]
  end

  
  def self.ransackable_attributes(auth_object = nil)
    %w[
      id
      name
      email
      phone
      event_title
      event_description
      preferred_date
      preferred_time
      platform
      city
      country
      venue_address
      meeting_link
      is_remote
      status
      notes
      time_zone
      created_at
      updated_at
    ]
  end

  
  def location_type
    is_remote? ? "Remote" : "Physical"
  end
end
