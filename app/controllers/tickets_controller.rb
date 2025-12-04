class TicketsController < ApplicationController
  before_action :authenticate_user!

  def create
    @event = Event.find(params[:event_id])
    quantity = params[:quantity].to_i

    # Create Stripe Checkout Session
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: @event.title,
            description: "Ticket for #{@event.title}",
          },
          unit_amount: (@event.price * 100).to_i, # Amount in cents
        },
        quantity: quantity,
      }],
      mode: 'payment',
      success_url: event_url(@event, success: true),
      cancel_url: event_url(@event, canceled: true),
      metadata: {
        event_id: @event.id,
        user_id: current_user.id,
        quantity: quantity
      }
    )

    render json: { url: session.url }
  rescue Stripe::StripeError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end