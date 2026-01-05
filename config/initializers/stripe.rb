# config/initializers/stripe.rb

require "stripe"

Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")

Rails.configuration.stripe = {
  publishable_key: ENV.fetch("STRIPE_PUBLISHABLE_KEY"),
  secret_key: ENV.fetch("STRIPE_SECRET_KEY")
}
