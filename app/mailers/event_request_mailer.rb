
class EventRequestMailer < ApplicationMailer
  default from: 'no-reply@example.com' # change

  def submission_confirmation
    @event_request = params[:event_request]
    mail(to: @event_request.email, subject: "We received your event request")
  end

  def approved_email
    @event_request = params[:event_request]
    @event = params[:event]
    mail(to: @event_request.email, subject: "Your event request has been approved")
  end
end
