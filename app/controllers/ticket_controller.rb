class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [:create]

  def create
    quantity = params[:quantity].to_i
    
    if quantity < 1 || quantity > 10
      redirect_to event_path(@event), alert: "Please select between 1 and 10 tickets."
      return
    end

    # Check if user already has a registration
    existing_registration = @event.registrations.find_by(user: current_user)
    if existing_registration
      redirect_to event_path(@event), alert: "You are already registered for this event."
      return
    end

    # Calculate total amount
    total_amount = @event.price * quantity

    # Create Stripe Checkout Session
    begin
      session = Stripe::Checkout::Session.create({
        payment_method_types: ['card'],
        line_items: [{
          price_data: {
            currency: 'usd',
            product_data: {
              name: @event.title,
              description: "#{quantity} ticket(s) for #{@event.title}",
              images: [@event.image_url.present? ? @event.image_url : "https://via.placeholder.com/400x300"],
            },
            unit_amount: (@event.price * 100).to_i, # Stripe uses cents
          },
          quantity: quantity,
        }],
        mode: 'payment',
        success_url: ticket_success_url(event_id: @event.id),
        cancel_url: event_url(@event),
        metadata: {
          event_id: @event.id,
          user_id: current_user.id,
          quantity: quantity
        }
      })

      redirect_to session.url, allow_other_host: true
    rescue Stripe::StripeError => e
      redirect_to event_path(@event), alert: "Payment processing error: #{e.message}"
    end
  end

  def success
    @event = Event.find(params[:event_id])
    @registration = @event.registrations.find_by(user: current_user)
    
    if @registration
      flash[:notice] = "Payment successful! Your tickets have been confirmed."
    else
      flash[:alert] = "Registration not found. Please contact support."
    end
  end

  def my_tickets
    @tickets = current_user.tickets.includes(:event).order(created_at: :desc)
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end
end