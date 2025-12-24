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
      
      Registration.create!(
        event_id: session.metadata.event_id,
        user_id: session.metadata.user_id,
        quantity: session.metadata.quantity,
        payment_status: 'paid'
      )
    end

    render json: { message: 'Success' }, status: 200
  end
end