class RegistrationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event

  def create
    @registration = @event.registrations.new(user: current_user, status: "registered")

    if @registration.save
      flash[:notice] = "Successfully registered for #{@event.title}"
    else
      flash[:alert] = @registration.errors.full_messages.to_sentence
    end

    redirect_to event_path(@event)
  end

  def destroy
    @registration = @event.registrations.find_by(user: current_user)
    if @registration&.destroy
      flash[:notice] = "Registration cancelled."
    else
      flash[:alert] = "Could not cancel registration."
    end
    redirect_to event_path(@event)
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end
end
