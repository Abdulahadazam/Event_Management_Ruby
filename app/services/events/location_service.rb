# frozen_string_literal: true

require 'ostruct'

module Events
  class LocationService
    DEFAULT_LOCATIONS = {
      'Lahore' => { latitude: 31.5204, longitude: 74.3587 },
      'Karachi' => { latitude: 24.8607, longitude: 67.0011 },
      'Islamabad' => { latitude: 33.6844, longitude: 73.0479 }
    }.freeze
    
    def self.get_location(params)
      new(params).get_location
    end
    
    def initialize(params)
      @params = params
    end
    
    def get_location
      # Priority 1: URL params
      return from_params if params_present?
      
      # Priority 2: Session
      return from_session if session_present?
      
      # Priority 3: Default
      default_location
    end
    
    def store_location(session)
      if params_present?
        session[:user_latitude] = @params[:latitude]
        session[:user_longitude] = @params[:longitude]
        true
      else
        false
      end
    end
    
    private
    
    attr_reader :params
    
    def from_params
      {
        latitude: @params[:latitude].to_f,
        longitude: @params[:longitude].to_f
      }
    end
    
    def from_session
      {
        latitude: @params[:session][:user_latitude].to_f,
        longitude: @params[:session][:user_longitude].to_f
      }
    end
    
    def default_location
      DEFAULT_LOCATIONS['Lahore']
    end
    
    def params_present?
      @params[:latitude].present? && @params[:longitude].present?
    end
    
    def session_present?
      @params[:session]&.dig(:user_latitude).present? && 
      @params[:session]&.dig(:user_longitude).present?
    end
  end
end