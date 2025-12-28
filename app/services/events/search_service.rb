# frozen_string_literal: true

require 'ostruct'

module Events
  class SearchService
    def self.call(query, current_user)
      new(query, current_user).call
    end
    
    def initialize(query, current_user)
      @query = query
      @current_user = current_user
    end
    
    def call
      OpenStruct.new(
        events: events,
        user_location: user_location
      )
    end
    
    private
    
    attr_reader :query, :current_user
    
    def events
      return Event.none if query.blank?
      
      Event.search_with_location(
        query,
        lat: user_location&.dig(:latitude),
        lng: user_location&.dig(:longitude)
      )
    end
    
    def user_location
      @user_location ||= LocationService.get_location({})
    end
  end
end