class Event < ApplicationRecord
  include PgSearch::Model

  belongs_to :category, optional: true
  belongs_to :user, optional: true
  belongs_to :event_request, optional: true
  has_many :registrations, dependent: :destroy
  has_many :attendees, through: :registrations, source: :user
  has_one_attached :banner

  validates :title, presence: true
  validates :description, presence: true
  validates :location, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :date, presence: true

  
  pg_search_scope :search_by_all,
    against: {
      title: 'A',
      description: 'B',
      location: 'C'
    },
    associated_against: {
      category: :name
    },
    using: {
      tsearch: {
        prefix: true,
        any_word: true
      },
      trigram: {
        threshold: 0.3
      }
    }
  
  validates :latitude, numericality: { 
    greater_than_or_equal_to: -90, 
    less_than_or_equal_to: 90 
  }, allow_nil: true
  
  validates :longitude, numericality: { 
    greater_than_or_equal_to: -180, 
    less_than_or_equal_to: 180 
  }, allow_nil: true
  
  before_save :update_lonlat_from_coordinates, if: :coordinates_changed?
  before_save :geocode_location_if_needed, if: :should_geocode?
  
  
  scope :within_radius, ->(lat, lng, radius_km) {
    where(
      "ST_DWithin(
        lonlat, 
        ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, 
        ?
      )", 
      lng, lat, radius_km * 1000 
    )
  }
  
  scope :order_by_distance, ->(lat, lng) {
    select(
      "events.*, 
       ST_Distance(
         lonlat, 
         ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography
       ) as distance_in_meters", 
      lng, lat
    ).order("distance_in_meters ASC")
  }
  
  scope :with_coordinates, -> { where.not(latitude: nil, longitude: nil) }
  
  scope :upcoming, -> { where("date >= ?", Date.today).order(date: :asc) }

  scope :past, -> { where("date < ?", Date.today).order(date: :desc) }

  # Scopes for admin filtering
  scope :from_requests, -> { where.not(event_request_id: nil) }
  scope :manual, -> { where(event_request_id: nil) }
  scope :remote, -> { where(is_remote: true) }
  scope :physical, -> { where(is_remote: [false, nil]) }
  
  
  def banner_url
    return nil unless banner.attached?
    Rails.application.routes.url_helpers.rails_blob_path(banner, only_path: true)
  rescue ActiveRecord::InverseOfAssociationNotFoundError
    nil
  end
  
  def attendees_count
    registrations.sum(:tickets)
  end
  
  def registered?(user)
    return false unless user
    registrations.exists?(user_id: user.id)
  end
  
  def distance_from(lat, lng)
    return nil unless has_coordinates?
    
    sql = "ST_Distance(
            lonlat, 
            ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography
          ) as distance"
    
    result = Event.select(sql, lng, lat).where(id: id).first
    return nil unless result.distance
    
    (result.distance / 1000.0).round(2)  
  rescue
    nil
  end
  
  def has_coordinates?
    latitude.present? && longitude.present?
  end
  
  def distance_from_formatted(lat, lng)
    dist = distance_from(lat, lng)
    return nil unless dist
    
    if dist < 1
      "#{(dist * 1000).round(0)} m away"
    else
      "#{dist} km away"
    end
  end
  
  def google_maps_url
    return nil unless has_coordinates?

    "https://www.google.com/maps/search/?api=1&query=#{latitude},#{longitude}"
  end
  
  def coordinates_array
    return nil unless has_coordinates?

    [latitude, longitude]
  end

  # Helper methods for new fields
  def location_type
    is_remote? ? "Remote" : "Physical"
  end

  def from_event_request?
    event_request_id.present?
  end

  def manually_created?
    event_request_id.nil?
  end

  def source_label
    from_event_request? ? "Approved Request" : "Manually Created"
  end
  
  
  def self.nearby(lat, lng, radius_km = 50)
    within_radius(lat, lng, radius_km)
      .order_by_distance(lat, lng)
  end
  
  def self.search_with_location(query, lat: nil, lng: nil, radius_km: 50)
    results = where(
      "title ILIKE ? OR description ILIKE ? OR location ILIKE ?", 
      "%#{query}%", "%#{query}%", "%#{query}%"
    )
    
    if lat.present? && lng.present?
      results = results.within_radius(lat, lng, radius_km)
                      .order_by_distance(lat, lng)
    end
    
    results
  end
  
  def self.by_city
    group(:location).count
  end
  
  def self.in_city(city_name, user_lat: nil, user_lng: nil)
    results = where("location ILIKE ?", "%#{city_name}%")
    
    if user_lat && user_lng
      results = results.order_by_distance(user_lat, user_lng)
    else
      results = results.order(date: :asc)
    end
    
    results
  end
  
  def self.ransackable_attributes(auth_object = nil)
    %w[id title description date location created_at updated_at category_id price latitude longitude
       organizer_name organizer_email organizer_phone is_remote city country event_capacity]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[registrations category attendees]
  end
  
  private
  
  def coordinates_changed?
    latitude_changed? || longitude_changed?
  end
  
  def update_lonlat_from_coordinates
    if latitude.present? && longitude.present?
      self.lonlat = "POINT(#{longitude} #{latitude})"
    else
      self.lonlat = nil
    end
  end
  
  def should_geocode?
    location.present? && !has_coordinates? && (location_changed? || new_record?)
  end
  
  def geocode_location_if_needed
    return if location.blank?
    
    coords = Events::GeocodingService.geocode(location)
    
    if coords
      self.latitude = coords[:latitude]
      self.longitude = coords[:longitude]
    end
  rescue StandardError => e
    Rails.logger.error "Geocoding failed for location: #{location} - #{e.message}"
    # Don't fail the save if geocoding fails
  end
end