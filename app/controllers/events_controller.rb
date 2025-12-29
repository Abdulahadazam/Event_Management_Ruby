class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  
  
  def index
    result = Events::FilterService.call(params, current_user)
    
    @events = result.events
    @categories = result.categories
    @cities = result.cities
    @user_location = result.user_location
  end
  
  
  def show
    # Geocode event location if coordinates are missing
    if @event.location.present? && !@event.has_coordinates?
      Events::GeocodingService.geocode_and_update(@event)
    end
    
    result = Events::ShowService.call(@event, params, current_user)
    
    @user_location = result.user_location
    @distance = result.distance
    @distance_formatted = result.distance_formatted
    @nearby_events = result.nearby_events
    @registration = result.registration
    @map_data = result.map_data
    
    handle_payment_flash
  end
  
  def new
    @event = current_user.events.build
  end
  
  def create
    result = Events::CreateService.call(current_user, params)
    
    if result.success
      redirect_to result.event, notice: 'Event was successfully created.'
    else
      @event = result.event
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    authorize_event_owner!
  end
  
  def update
    authorize_event_owner!
    
    result = Events::UpdateService.call(@event, params)
    
    if result.success
      redirect_to result.event, notice: 'Event was successfully updated.'
    else
      @event = result.event
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    authorize_event_owner!
    
    @event.destroy
    redirect_to events_url, notice: 'Event was successfully deleted.'
  end
  
  
  def nearby
    result = Events::NearbyService.call(params)
    render json: result.to_json
  end
  
  def search
    @query = params[:q]
    result = Events::SearchService.call(@query, current_user)
    
    @events = result.events
    @user_location = result.user_location
    
    render :index
  end
  
  private
  
  def set_event
    @event = Event.find(params[:id])
  end
  
  def event_params
    params.require(:event).permit(
      :title, :description, :location, :date, :price, :category_id,
      :latitude, :longitude, :image_url, :banner
    )
  end
  
  def authorize_event_owner!
    unless @event.user_id == current_user.id
      redirect_to root_path, alert: "You don't have permission to perform this action."
    end
  end
  
  def handle_payment_flash
    if params[:success]
      flash[:notice] = "Payment successful! Ticket confirmation email has been sent to your email address."
    elsif params[:canceled]
      flash[:alert] = "Payment was canceled."
    end
  end
end