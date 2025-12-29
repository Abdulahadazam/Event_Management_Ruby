# frozen_string_literal: true

require 'ostruct'

module Events
  class UpdateService
    attr_reader :event, :params
    
    def self.call(event, params)
      new(event, params).call
    end
    
    def initialize(event, params)
      @event = event
      @params = params
    end
    
    def call
      # Geocode location if it changed and coordinates are not provided
      if location_changed? && !coordinates_provided?
        geocode_location
      end
      
      if @event.update(event_params)
        OpenStruct.new(success: true, event: @event, errors: nil)
      else
        OpenStruct.new(success: false, event: @event, errors: @event.errors)
      end
    end
    
    private
    
    def event_params
      @params.require(:event).permit(
        :title, :description, :location, :date, :price, :category_id,
        :latitude, :longitude, :image_url, :banner
      )
    end
    
    def location_changed?
      @params[:event][:location].present? && 
      @params[:event][:location] != @event.location
    end
    
    def coordinates_provided?
      @params[:event][:latitude].present? && @params[:event][:longitude].present?
    end
    
    def geocode_location
      location = @params[:event][:location]
      return if location.blank?
      
      coords = GeocodingService.geocode(location)
      
      if coords
        @params[:event][:latitude] = coords[:latitude]
        @params[:event][:longitude] = coords[:longitude]
      end
    rescue StandardError => e
      Rails.logger.error "Geocoding failed for location: #{location} - #{e.message}"
      # Don't fail the update if geocoding fails
    end
  end
end


