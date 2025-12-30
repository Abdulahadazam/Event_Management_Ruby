# frozen_string_literal: true

require 'ostruct'

module Events
  class FilterService
    attr_reader :params, :current_user
    
    def self.call(params, current_user)
      new(params, current_user).call
    end
    
    def initialize(params, current_user)
      @params = params
      @current_user = current_user
    end
    
    def call
      OpenStruct.new(
        events: filtered_events,
        categories: categories,
        cities: cities,
        user_location: user_location
      )
    end
    
    private
    
    def filtered_events
      events = Event.includes(:category, :registrations).upcoming
      
      events = apply_category_filter(events)
      events = apply_city_filter(events)
      events = apply_price_filters(events)
      events = apply_search_filter(events)
      events = apply_location_filter(events)
      
      events
    end
    
    def apply_category_filter(events)
      if params[:category].present?
        category = Category.find_by("LOWER(name) = ?", params[:category].downcase)
        return events.where(category_id: category.id) if category
      end
      
      if params[:category_id].present? && params[:category_id] != ""
        return events.where(category_id: params[:category_id])
      end
      
      events
    end
    
    def apply_city_filter(events)
      if params[:city].present? && params[:city] != ""
        events.where("location ILIKE ?", "%#{params[:city]}%")
      else
        events
      end
    end
    
    def apply_price_filters(events)
      events = events.where("price >= ?", params[:min_price]) if params[:min_price].present?
      events = events.where("price <= ?", params[:max_price]) if params[:max_price].present?
      events
    end
    
    def apply_search_filter(events)
      if params[:search].present? && params[:search].strip.length > 0
        
        events.search_by_all(params[:search].strip)
      else
        events
      end
    end
    
    def apply_location_filter(events)
      # If no user location, just return events ordered by date
      return events.order(date: :asc) unless user_location.present?

      lat = user_location[:latitude].to_f
      lng = user_location[:longitude].to_f
      radius = params[:radius]&.to_i || 50

      
      radius_meters = radius * 1000

    
      sql = <<~SQL
        SELECT events.*,
               ST_Distance(
                 lonlat,
                 ST_SetSRID(ST_MakePoint(#{lng}, #{lat}), 4326)::geography
               ) as distance_in_meters
        FROM events
        WHERE events.id IN (#{events.select(:id).to_sql})
          AND ST_DWithin(
            lonlat,
            ST_SetSRID(ST_MakePoint(#{lng}, #{lat}), 4326)::geography,
            #{radius_meters}
          )
        ORDER BY distance_in_meters ASC
      SQL

    
      nearby_events = Event.find_by_sql(sql)

      
      nearby_events.map do |event|
        event.define_singleton_method(:user_distance) do
          distance_from(lat, lng)
        end
        event.define_singleton_method(:user_distance_formatted) do
          distance_from_formatted(lat, lng)
        end
        event
      end
    end
    
    def user_location
      @user_location ||= LocationService.get_location(params)
    end
    
    def cities
      Event.pluck(:location)
           .map { |loc| loc.split(',').last&.strip }
           .uniq
           .compact
           .sort
    end
    
    def categories
      Category.all.order(:name)
    end
  end
end