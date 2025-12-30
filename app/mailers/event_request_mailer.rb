class EventRequestMailer < ApplicationMailer
  default from: 'noreply@eventhub.com'

  def submission_confirmation
    @event_request = params[:event_request]
    mail(to: @event_request.organizer_email, subject: "✅ We received your event request - EventHub")
  end

  def approved_email
    @event_request = params[:event_request]
    @event = params[:event]
    mail(to: @event_request.organizer_email, subject: "🎉 Your event request has been approved! - EventHub")
  end

  def rejected_email
    @event_request = params[:event_request]
    @rejection_reason = params[:rejection_reason] || "Unfortunately, we cannot approve your event request at this time."
    mail(to: @event_request.organizer_email, subject: "Event Request Update - EventHub")
  end
end
