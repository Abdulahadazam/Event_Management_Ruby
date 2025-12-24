class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  
  def index
    @events = Event.includes(:category, :registrations).upcoming
    
    @user_location = get_user_location
    
    
    if params[:category].present?
      category = Category.find_by("LOWER(name) = ?", params[:category].downcase)
      @events = @events.where(category_id: category.id) if category
    end
    
    if params[:category_id].present? && params[:category_id] != ""
      @events = @events.where(category_id: params[:category_id])
    end
    
    if params[:city].present? && params[:city] != ""
      @events = @events.where("location ILIKE ?", "%#{params[:city]}%")
    end
    
    if params[:min_price].present?
      @events = @events.where("price >= ?", params[:min_price])
    end
    
    if params[:max_price].present?
      @events = @events.where("price <= ?", params[:max_price])
    end
    
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @events = @events.where(
        "title ILIKE ? OR description ILIKE ? OR location ILIKE ?", 
        search_term, search_term, search_term
      )
    end
    
    if @user_location.present?
      lat = @user_location[:latitude]
      lng = @user_location[:longitude]
      radius = params[:radius]&.to_i || 50
      
      @events = @events.nearby(lat, lng, radius)
      
      @events = @events.to_a.map do |event|
        event.define_singleton_method(:user_distance) do
          distance_from(lat, lng)
        end
        event.define_singleton_method(:user_distance_formatted) do
          distance_from_formatted(lat, lng)
        end
        event
      end
    else
      @events = @events.order(date: :asc).to_a
    end
    
    @cities = Event.pluck(:location)
                   .map { |loc| loc.split(',').last&.strip }
                   .uniq
                   .compact
                   .sort
    
    @categories = Category.all.order(:name)
  end
  
  def show
    @user_location = get_user_location
    
    if @event.has_coordinates? && @user_location.present?
      @distance = @event.distance_from(
        @user_location[:latitude], 
        @user_location[:longitude]
      )
      @distance_formatted = @event.distance_from_formatted(
        @user_location[:latitude], 
        @user_location[:longitude]
      )
    end
    
    if @event.has_coordinates?
      @nearby_events = Event.where.not(id: @event.id)
                           .nearby(@event.latitude, @event.longitude, 20)
                           .limit(3)
      
      if @event.category_id.present?
        @nearby_events = @nearby_events.where(category_id: @event.category_id)
      end
    end
    
    @registration = @event.registrations.find_by(user: current_user) if user_signed_in?
    
    if params[:success]
      flash.now[:notice] = "Payment successful! Your ticket has been confirmed."
    elsif params[:canceled]
      flash.now[:alert] = "Payment was canceled."
    end
  end
  
  def new
    @event = current_user.events.build
  end
  
  def create
    @event = current_user.events.build(event_params)
    
    if @event.save
      redirect_to @event, notice: 'Event was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    unless @event.user_id == current_user.id
      redirect_to root_path, alert: "You don't have permission to edit this event."
    end
  end
  
  def update
    unless @event.user_id == current_user.id
      redirect_to root_path, alert: "You don't have permission to edit this event."
      return
    end
    
    if @event.update(event_params)
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    unless @event.user_id == current_user.id
      redirect_to root_path, alert: "You don't have permission to delete this event."
      return
    end
    
    @event.destroy
    redirect_to events_url, notice: 'Event was successfully deleted.'
  end
  
  def nearby
    lat = params[:latitude].to_f
    lng = params[:longitude].to_f
    radius = params[:radius]&.to_i || 50
    
    @events = Event.nearby(lat, lng, radius).limit(10)
    
    respond_to do |format|
      format.json do
        render json: @events.map { |event|
          {
            id: event.id,
            title: event.title,
            location: event.location,
            latitude: event.latitude,
            longitude: event.longitude,
            price: event.price,
            date: event.date,
            distance: event.distance_from(lat, lng),
            url: event_path(event)
          }
        }
      end
    end
  end
  
  def search
    @query = params[:q]
    @user_location = get_user_location
    
    if @query.present?
      @events = Event.search_with_location(
        @query,
        lat: @user_location&.dig(:latitude),
        lng: @user_location&.dig(:longitude)
      )
    else
      @events = Event.none
    end
    
    render :index
  end
  
  private
  
  def set_event
    @event = Event.find(params[:id])
  end
  
  def event_params
    params.require(:event).permit(
      :title, 
      :description, 
      :location, 
      :date, 
      :price, 
      :category_id,
      :latitude,
      :longitude,
      :image_url, 
      :banner
    )
  end
  
  def get_user_location
    if params[:latitude].present? && params[:longitude].present?
      return {
        latitude: params[:latitude].to_f,
        longitude: params[:longitude].to_f
      }
    end
    
    if session[:user_latitude].present? && session[:user_longitude].present?
      return {
        latitude: session[:user_latitude].to_f,
        longitude: session[:user_longitude].to_f
      }
    end
    
    default_locations = {
      'Lahore' => { latitude: 31.5204, longitude: 74.3587 },
      'Karachi' => { latitude: 24.8607, longitude: 67.0011 },
      'Islamabad' => { latitude: 33.6844, longitude: 73.0479 }
    }
    
    default_locations['Lahore']
  end
  
  def store_location
    if params[:latitude].present? && params[:longitude].present?
      session[:user_latitude] = params[:latitude]
      session[:user_longitude] = params[:longitude]
      
      render json: { success: true }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end
end