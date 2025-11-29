class EventRequestsController < ApplicationController
  def new
    @event_request = EventRequest.new
  end

  def create
    @event_request = EventRequest.new(event_request_params)
    if @event_request.save
      redirect_to root_path, notice: "Your event request has been submitted successfully."
    else
      flash.now[:alert] = "Please correct the errors below."
      render :new
    end
  end
   
  private

  def event_request_params
    params.require(:event_request).permit(
      :name, :email, :phone, :event_name, :event_type, :event_mode, 
      :location, :date, :time, :expected_guests, :budget, :description, :special_requirements
    )
  end   
end
