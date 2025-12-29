# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

module Events
  class GeocodingService
    NOMINATIM_BASE_URL = 'https://nominatim.openstreetmap.org/search'.freeze
    
    # Known locations cache for common places
    LOCATION_CACHE = {
      'dha lahore' => { latitude: 31.4707, longitude: 74.3772 },
      'dha' => { latitude: 31.4707, longitude: 74.3772 },
      'lahore' => { latitude: 31.5204, longitude: 74.3587 },
      'karachi' => { latitude: 24.8607, longitude: 67.0011 },
      'islamabad' => { latitude: 33.6844, longitude: 73.0479 },
      'rawalpindi' => { latitude: 33.5651, longitude: 73.0169 },
      'faisalabad' => { latitude: 31.4504, longitude: 73.1350 },
      'multan' => { latitude: 30.1575, longitude: 71.5249 },
      'peshawar' => { latitude: 34.0151, longitude: 71.5249 }
    }.freeze
    
  def self.geocode(location_string)
    new(location_string).geocode
  end
  
  def self.geocode_and_update(event)
    return if event.location.blank? || event.has_coordinates?
    
    coords = geocode(event.location)
    
    if coords && coords[:latitude] && coords[:longitude]
      # Use update_columns to skip callbacks and validations for faster update
      event.update_columns(
        latitude: coords[:latitude],
        longitude: coords[:longitude],
        lonlat: "POINT(#{coords[:longitude]} #{coords[:latitude]})"
      )
      event.reload
    end
  rescue StandardError => e
    Rails.logger.error "Geocoding failed for event #{event.id}: #{e.message}"
  end
    
    def initialize(location_string)
      @location_string = location_string.to_s.strip.downcase
    end
    
    def geocode
      return nil if @location_string.blank?
      
      # Check cache first
      cached = check_cache
      return cached if cached
      
      # Try geocoding API
      result = fetch_from_nominatim
      return result if result
      
      # Fallback to default
      default_location
    end
    
    private
    
    def check_cache
      LOCATION_CACHE.each do |key, coords|
        return coords if @location_string.include?(key)
      end
      nil
    end
    
    def fetch_from_nominatim
      uri = URI(NOMINATIM_BASE_URL)
      params = {
        q: @location_string,
        format: 'json',
        limit: 1,
        addressdetails: 1
      }
      uri.query = URI.encode_www_form(params)
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 5
      
      request = Net::HTTP::Get.new(uri)
      request['User-Agent'] = 'EventManagementPlatform/1.0'
      
      response = http.request(request)
      
      if response.code == '200'
        data = JSON.parse(response.body)
        if data.is_a?(Array) && data.first
          {
            latitude: data.first['lat'].to_f,
            longitude: data.first['lon'].to_f,
            display_name: data.first['display_name']
          }
        end
      end
    rescue StandardError => e
      Rails.logger.error "Geocoding error: #{e.message}"
      nil
    end
    
    def default_location
      { latitude: 31.5204, longitude: 74.3587 } # Default to Lahore
    end
  end
end

