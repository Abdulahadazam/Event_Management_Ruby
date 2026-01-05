class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :event
  belongs_to :registration

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending paid cancelled] }
  validates :ticket_type, presence: true
  
  after_create :generate_ticket_number
  after_create :send_confirmation_email, if: -> { status == 'paid' }

  TICKET_TYPES = ['Standard', 'VIP', 'Premium'].freeze


  scope :paid, -> { where(status: 'paid') }
  scope :pending, -> { where(status: 'pending') }
  scope :cancelled, -> { where(status: 'cancelled') }

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "event_id", "id", "payment_id", "payment_method", "quantity",
     "registration_id", "status", "ticket_type", "total_amount", "updated_at",
     "user_id", "ticket_number"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user", "event", "registration"]
  end

  def qr_code_data
    "TICKET-#{id}-EVENT-#{event_id}-USER-#{user_id}"
  end
  
  def purchased?
    status == 'paid'
  end

  private

  def generate_ticket_number
    update(ticket_number: "EVT-#{event_id}-#{id.to_s.rjust(6, '0')}")
  end
  
  def send_confirmation_email
    begin
      TicketMailer.with(ticket: self).confirmation_email.deliver_now
    rescue => e
      Rails.logger.error "Failed to send ticket confirmation email: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      # Don't raise error - ticket is already created, email failure shouldn't break the flow
    end
  end
end