# app/models/event_request.rb
class EventRequest < ApplicationRecord
  enum status: { pending: 0, approved: 1, rejected: 2 }

  belongs_to :category, class_name: "Category", optional: true # if you have Category model
  has_one_attached :banner

  validates :name, :email, :event_title, :event_description, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  # convenience for admin
  def location_type
    is_remote? ? "Remote" : "Physical"
  end
end
