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
      user_loc = user_location
      
      OpenStruct.new(
        user_location: user_loc,
        distance: distance(user_loc),
        distance_formatted: distance_formatted(user_loc),
        nearby_events: nearby_events,
        registration: registration,
        map_data: MapService.call(event, user_loc)
      )
    end
    
    private
    
    def user_location
      @user_location ||= LocationService.get_location(params)
    end
    
    def distance(user_loc)
      return nil unless event.has_coordinates? && user_loc.present?
      
      event.distance_from(
        user_loc[:latitude],
        user_loc[:longitude]
      )
    end
    
    def distance_formatted(user_loc)
      return nil unless event.has_coordinates? && user_loc.present?
      
      event.distance_from_formatted(
        user_loc[:latitude],
        user_loc[:longitude]
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