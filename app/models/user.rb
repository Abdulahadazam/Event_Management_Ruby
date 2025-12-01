class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :registrations
  has_many :events, through: :registrations
  has_many :organized_events, class_name: "Event", foreign_key: :organizer_id

  
  def self.ransackable_associations(auth_object = nil)
    ["events", "organized_events", "registrations"]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id email created_at updated_at role]
  end

   
  def self.from_google(auth)
    where(email: auth.info.email).first_or_create do |user|
      user.name  = auth.info.name
      user.email = auth.info.email
      user.password = SecureRandom.hex(10)
    end
  end
end
