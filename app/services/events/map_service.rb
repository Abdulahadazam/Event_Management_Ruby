# frozen_string_literal: true

require 'ostruct'

module Events
  class MapService
    attr_reader :event, :user_location
    
    def self.call(event, user_location = nil)
      new(event, user_location).call
    end
    
    def initialize(event, user_location = nil)
      @event = event
      @user_location = user_location
    end
    
    def call
      OpenStruct.new(
        has_coordinates: event.has_coordinates?,
        latitude: event.latitude,
        longitude: event.longitude,
        location: event.location,
        map_center: map_center,
        zoom_level: zoom_level,
        markers: markers,
        user_location: user_location,
        distance: distance,
        distance_formatted: distance_formatted,
        google_maps_url: event.google_maps_url
      )
    end
    
    private
    
    def map_center
      if event.has_coordinates?
        [event.latitude, event.longitude]
      elsif user_location
        [user_location[:latitude], user_location[:longitude]]
      else
        [31.5204, 74.3587] # Default to Lahore
      end
    end
    
    def zoom_level
      if event.has_coordinates? && user_location
        # Calculate zoom based on distance
        dist = distance
        return 15 if dist.nil?
        return 18 if dist < 1 # Less than 1km
        return 15 if dist < 5 # Less than 5km
        return 13 if dist < 20 # Less than 20km
        12
      elsif event.has_coordinates?
        15
      else
        12
      end
    end
    
    def markers
      markers = []
      
      # Event marker
      if event.has_coordinates?
        markers << {
          type: 'event',
          latitude: event.latitude,
          longitude: event.longitude,
          title: event.title,
          location: event.location,
          popup: event.location
        }
      end
      
      # User location marker (if available)
      if user_location
        markers << {
          type: 'user',
          latitude: user_location[:latitude],
          longitude: user_location[:longitude],
          title: 'Your Location',
          popup: 'Your Location'
        }
      end
      
      markers
    end
    
    def distance
      return nil unless event.has_coordinates? && user_location
      
      event.distance_from(
        user_location[:latitude],
        user_location[:longitude]
      )
    end
    
    def distance_formatted
      return nil unless distance
      
      event.distance_from_formatted(
        user_location[:latitude],
        user_location[:longitude]
      )
    end
  end
end


