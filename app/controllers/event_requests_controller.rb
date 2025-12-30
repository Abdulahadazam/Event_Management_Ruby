class EventRequestsController < ApplicationController
  def new
    @event_request = EventRequest.new
  end

  def create
    @event_request = EventRequest.new(event_request_params)
    if @event_request.save
      
      EventRequestMailer.with(event_request: @event_request).submission_confirmation.deliver_later

      redirect_to root_path, notice: "🎉 Thank you! Your event request has been submitted successfully. Our team will review it and contact you within 24-48 hours at #{@event_request.organizer_email}."
    else
      flash.now[:alert] = "Please correct the errors below."
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @event_request = EventRequest.find(params[:id])
  end

  private

  def event_request_params
    params.require(:event_request).permit(
      :organizer_name, :organizer_email, :organizer_phone,
      :event_title, :event_description, :category_id,
      :preferred_date, :preferred_time,
      :is_remote, :venue_address, :city, :country,
      :platform, :meeting_link, :time_zone,
      :ticket_price, :event_capacity,
      :has_multiple_ticket_types, :standard_ticket_price, :vip_ticket_price, :premium_ticket_price,
      :notes, :banner
    )
  end
end
