class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :event
  belongs_to :registration

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending paid cancelled] }
  
  after_create :generate_ticket_number

  def qr_code_data
    "TICKET-#{id}-EVENT-#{event_id}-USER-#{user_id}"
  end

  private

  def generate_ticket_number
    update(ticket_number: "EVT-#{event_id}-#{id.to_s.rjust(6, '0')}")
  end
end