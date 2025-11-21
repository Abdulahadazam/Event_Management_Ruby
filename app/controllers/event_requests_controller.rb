
class EventRequestsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create] 

  def new
    @event_request = EventRequest.new
  end

  def create
    @event_request = EventRequest.new(event_request_params)
    if @event_request.save
     
      EventRequestMailer.with(event_request: @event_request).submission_confirmation.deliver_later
      redirect_to @event_request, notice: "Request submitted. We'll review and get back to you."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @event_request = EventRequest.find(params[:id])
  end

  private

  def event_request_params
    params.require(:event_request).permit(
      :name, :email, :phone,
      :event_title, :event_description, :preferred_date, :preferred_time,
      :is_remote, :venue_address, :city, :country,
      :platform, :meeting_link, :time_zone,
      :event_category_id, :banner, :notes
    )
  end
end
