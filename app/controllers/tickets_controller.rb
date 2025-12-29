class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [:new, :create]
  before_action :ensure_registered, only: [:new, :create]
  before_action :store_location_for_authentication, only: [:new], if: -> { !user_signed_in? }

  def index
    @tickets = current_user.tickets.where(status: 'paid').includes(:event, :registration).order(created_at: :desc)
    @upcoming_tickets = @tickets.select { |t| t.event.date.present? && t.event.date >= Date.today }
    @past_tickets = @tickets.select { |t| t.event.date.present? && t.event.date < Date.today }
  end

  def show
    @ticket = current_user.tickets.find(params[:id])
  end

  def new
    @quantity = params[:quantity]&.to_i || 1
    @ticket_types = [
      { name: 'Standard', price: @event.price, available: true },
      { name: 'VIP', price: @event.price * 1.5, available: true },
      { name: 'Premium', price: @event.price * 2.0, available: true }
    ]
    @selected_ticket_type = params[:ticket_type] || @ticket_types.first[:name]
    @total_amount = calculate_total(@quantity, @selected_ticket_type)
    @is_registered = @event.registered?(current_user) if user_signed_in?
  end

  def create
    @event = Event.find(params[:event_id])
    quantity = params[:quantity].to_i
    ticket_type = params[:ticket_type] || 'Standard'
    
    # Backend validation: ensure user is registered (this is the source of truth)
    unless @event.registered?(current_user)
      render json: { 
        error: "Please register for this event first before purchasing tickets.",
        requires_registration: true,
        event_url: event_path(@event)
      }, status: :forbidden
      return
    end
    
    # Calculate price based on ticket type
    ticket_price = calculate_ticket_price(ticket_type)
    total_amount = ticket_price * quantity

    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: "#{@event.title} - #{ticket_type} Ticket",
            description: "#{ticket_type} ticket for #{@event.title}",
          },
          unit_amount: (ticket_price * 100).to_i, 
        },
        quantity: quantity,
      }],
      mode: 'payment',
      success_url: event_url(@event, success: true),
      cancel_url: event_url(@event, canceled: true),
      metadata: {
        event_id: @event.id,
        user_id: current_user.id,
        quantity: quantity,
        ticket_type: ticket_type,
        total_amount: total_amount.to_s
      }
    )

    render json: { url: session.url }
  rescue Stripe::StripeError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def ensure_registered
    unless @event.registered?(current_user)
      # Always return JSON error for API requests (AJAX/fetch)
      if request.format.json? || request.xhr?
        render json: { 
          error: "Please register for this event first before purchasing tickets.",
          requires_registration: true,
          event_url: event_path(@event)
        }, status: :forbidden
        return
      else
        # For regular page requests, redirect with flash message
        redirect_to event_path(@event), alert: "Please register for this event first before purchasing tickets."
        return
      end
    end
  end
  
  def calculate_total(quantity, ticket_type)
    ticket_price = calculate_ticket_price(ticket_type)
    ticket_price * quantity
  end
  
  def calculate_ticket_price(ticket_type)
    case ticket_type
    when 'VIP'
      @event.price * 1.5
    when 'Premium'
      @event.price * 2.0
    else
      @event.price
    end
  end
end
