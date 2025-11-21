class Registration < ApplicationRecord
  belongs_to :user
  belongs_to :event, counter_cache: true


  def self.ransackable_associations(auth_object = nil)
    ["event", "user"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["tickets","status", "created_at", "event_id", "user_id"]
  end

  validates :user_id, uniqueness: { scope: :event_id, message: "already registered for this event" }
  validates :status, presence: true

  after_create :send_confirmation_email_async
 private

  def send_confirmation_email_async
    # enable this if you implement the mailer below
    # RegistrationMailer.with(registration: self).confirmation_email.deliver_later
  end
end
