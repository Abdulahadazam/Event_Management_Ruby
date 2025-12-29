class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET'] 

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      render json: { error: e.message }, status: 400
      return
    end

    if event['type'] == 'checkout.session.completed'
      session = event['data']['object']
      
      begin
        event_obj = Event.find(session.metadata['event_id'])
        user = User.find(session.metadata['user_id'])
        quantity = session.metadata['quantity'].to_i
        ticket_type = session.metadata['ticket_type'] || 'Standard'
        total_amount = session.metadata['total_amount']&.to_f || (event_obj.price * quantity)
        registration = user.registrations.find_by(event: event_obj)
        
        if registration
          # Create ticket record (email will be sent automatically via after_create callback)
          ticket = Ticket.create!(
            user: user,
            event: event_obj,
            registration: registration,
            quantity: quantity,
            ticket_type: ticket_type,
            total_amount: total_amount,
            status: 'paid',
            payment_method: 'stripe',
            payment_id: session.id
          )
          
          Rails.logger.info "Ticket created successfully: #{ticket.id} for user #{user.id}, event #{event_obj.id}"
        else
          Rails.logger.error "Registration not found for user #{user.id} and event #{event_obj.id}"
        end
      rescue => e
        Rails.logger.error "Error processing webhook: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        # Still return 200 to prevent Stripe from retrying
      end
    end

    render json: { message: 'Success' }, status: 200
  end
end