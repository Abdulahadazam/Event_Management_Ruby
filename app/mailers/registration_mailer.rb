class RegistrationMailer < ApplicationMailer
  default from: 'noreply@eventhub.com'
  
  def confirmation_email
    @registration = params[:registration]
    @user = @registration.user
    @event = @registration.event
    
    mail(
      to: @user.email, 
      subject: "Complete Your Registration - Buy Tickets for #{@event.title}"
    )
  end
end
