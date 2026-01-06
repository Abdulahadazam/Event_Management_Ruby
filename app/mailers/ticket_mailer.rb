class TicketMailer < ApplicationMailer
  default from: 'noreply@eventhub.com'
  
  def confirmation_email
    @ticket = params[:ticket]
    @user = @ticket.user
    @event = @ticket.event
    @registration = @ticket.registration
    
    mail(
      to: @user.email,
      subject: "🎟️ Ticket Confirmation - #{@event.title}"
    )
  end
end



