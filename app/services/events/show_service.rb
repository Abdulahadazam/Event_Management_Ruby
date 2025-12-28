# frozen_string_literal: true

require 'ostruct'

module Events
  class ShowService
    attr_reader :event, :params, :current_user
    
    def self.call(event, params, current_user)
      new(event, params, current_user).call
    end
    
    def initialize(event, params, current_user)
      @event = event
      @params = params
      @current_user = current_user
    end
    
    def call
      OpenStruct.new(
        user_location: user_location,
        distance: distance,
        distance_formatted: distance_formatted,
        nearby_events: nearby_events,
        registration: registration
      )
    end
    
    private
    
    def user_location
      @user_location ||= LocationService.get_location(params)
    end
    
    def distance
      return nil unless event.has_coordinates? && user_location.present?
      
      event.distance_from(
        user_location[:latitude],
        user_location[:longitude]
      )
    end
    
    def distance_formatted
      return nil unless event.has_coordinates? && user_location.present?
      
      event.distance_from_formatted(
        user_location[:latitude],
        user_location[:longitude]
      )
    end
    
    def nearby_events
      return [] unless event.has_coordinates?
      
      events = Event.where.not(id: event.id)
                    .nearby(event.latitude, event.longitude, 20)
                    .limit(3)
      
      events = events.where(category_id: event.category_id) if event.category_id.present?
      
      events
    end
    
    def registration
      return nil unless current_user
      
      event.registrations.find_by(user: current_user)
    end
  end
end