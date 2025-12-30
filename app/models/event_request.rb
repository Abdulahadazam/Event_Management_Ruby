class EventRequest < ApplicationRecord
      enum :status, { pending: 0, approved: 1, rejected: 2 }, default: :pending


  belongs_to :category, class_name: "Category", optional: true
  has_one_attached :banner

  # Virtual attributes for ticket prices
  attr_accessor :standard_ticket_price, :vip_ticket_price, :premium_ticket_price

  validates :organizer_name, :organizer_email, :event_title, :event_description, presence: true
  validates :organizer_email, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_save :process_ticket_types

  private

  def process_ticket_types
    if has_multiple_ticket_types?
      types = {}
      types['Standard'] = standard_ticket_price.to_f if standard_ticket_price.present?
      types['VIP'] = vip_ticket_price.to_f if vip_ticket_price.present?
      types['Premium'] = premium_ticket_price.to_f if premium_ticket_price.present?
      self.ticket_types_data = types
    else
      self.ticket_types_data = {}
    end
  end

  public

  def self.ransackable_associations(auth_object = nil)
    ["banner_attachment", "banner_blob", "category"]
  end

  
  def self.ransackable_attributes(auth_object = nil)
    %w[
      id
      organizer_name
      organizer_email
      organizer_phone
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
      ticket_price
      event_capacity
      category_id
      created_at
      updated_at
    ]
  end

  
  def location_type
    is_remote? ? "Remote" : "Physical"
  end
end
