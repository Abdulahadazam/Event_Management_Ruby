class RegistrationMailer < ApplicationMailer
  def confirmation_email
    @registration = params[:registration]
    @user = @registration.user
    @event = @registration.event
    mail(to: @user.email, subject: "Registration confirmed for #{@event.title}")
  end
end
