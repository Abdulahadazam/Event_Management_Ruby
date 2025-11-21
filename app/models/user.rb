class User < ApplicationRecord
  



  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
   enum role: { attendee: 0, organizer: 1 }
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :registrations
  has_many :events, through: :registrations
  has_many :organized_events, class_name: "Event", foreign_key: :organizer_id

   def self.ransackable_associations(auth_object = nil)
    ["events", "organized_events", "registrations"]
  end

def self.ransackable_attributes(auth_object = nil)
  %w[id email created_at updated_at role]
end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
end
