# frozen_string_literal: true

require 'ostruct'

module Events
  class CreateService
    attr_reader :user, :params
    
    def self.call(user, params)
      new(user, params).call
    end
    
    def initialize(user, params)
      @user = user
      @params = params
    end
    
    def call
      event = user.events.build(event_params)
      
      # Geocode location if coordinates are not provided
      geocode_location(event) if event.location.present? && !event.has_coordinates?
      
      if event.save
        OpenStruct.new(success: true, event: event, errors: nil)
      else
        OpenStruct.new(success: false, event: event, errors: event.errors)
      end
    end
    
    private
    
    def event_params
      @params.require(:event).permit(
        :title, :description, :location, :date, :price, :category_id,
        :latitude, :longitude, :image_url, :banner
      )
    end
    
    def geocode_location(event)
      return if event.location.blank?
      
      coords = GeocodingService.geocode(event.location)
      
      if coords
        event.latitude = coords[:latitude]
        event.longitude = coords[:longitude]
      end
    rescue StandardError => e
      Rails.logger.error "Geocoding failed for location: #{event.location} - #{e.message}"
      # Don't fail the save if geocoding fails
    end
  end
end


