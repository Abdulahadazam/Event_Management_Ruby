# frozen_string_literal: true

require 'ostruct'
module Events
  class NearbyService
    def self.call(params)
      new(params).call
    end
    
    def initialize(params)
      @params = params
    end
    
    def call
      events.map { |event| format_event(event) }
    end
    
    def to_json
      call
    end
    
    private
    
    attr_reader :params
    
    def events
      Event.nearby(latitude, longitude, radius).limit(10)
    end
    
    def latitude
      params[:latitude].to_f
    end
    
    def longitude
      params[:longitude].to_f
    end
    
    def radius
      params[:radius]&.to_i || 50
    end
    
    def format_event(event)
      {
        id: event.id,
        title: event.title,
        location: event.location,
        latitude: event.latitude,
        longitude: event.longitude,
        price: event.price,
        date: event.date,
        distance: event.distance_from(latitude, longitude),
        url: Rails.application.routes.url_helpers.event_path(event)
      }
    end
  end
end