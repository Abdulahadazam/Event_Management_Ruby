class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable,  
         :omniauthable, omniauth_providers: [:google_oauth2]
         


  validates :name, presence: true, length: { minimum: 2, maximum: 50 }

  validate :password_complexity

  has_many :registrations
  has_many :events, through: :registrations
  has_many :organized_events, class_name: "Event", foreign_key: :organizer_id
  has_many :tickets, dependent: :destroy

  def self.ransackable_associations(auth_object = nil)
    ["events", "organized_events", "registrations", "tickets"]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id email created_at updated_at role name]
  end

  def self.from_google(auth)
    where(email: auth.info.email).first_or_create do |user|
      user.name  = auth.info.name
      user.email = auth.info.email
      user.password = SecureRandom.hex(10)
      user.skip_confirmation!  # Google already verified the email
    end
  end

  private

  def password_complexity
    return if password.blank?

    errors.add :password, 'must start with a capital letter' unless password.match?(/^[A-Z]/)
    errors.add :password, 'must be at least 8 characters' unless password.length >= 8
    errors.add :password, 'cannot contain sequential numbers like 123 or 321' if password.match?(/123|234|345|456|567|678|789|321|432|543|654|765|876|987/)
  end
end