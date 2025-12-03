# frozen_string_literal: true

Devise.setup do |config|
  # The secret key used by Devise. Devise uses this key to generate
  # random tokens. Changing this key will render invalid all existing
  # confirmation, reset password and unlock tokens.
  config.secret_key = ENV['DEVISE_SECRET_KEY'] if Rails.env.production?

  # ==> Mailer Configuration
  config.mailer_sender = 'please-change-me@example.com'

  require "devise/orm/active_record"

  # Case-insensitive keys (email, username, etc.)
  config.case_insensitive_keys = [:email]

  # Remove whitespace from email before saving
  config.strip_whitespace_keys = [:email]

  # Skip session storage for API requests
  config.skip_session_storage = [:http_auth]

  # Password hashing cost
  config.stretches = Rails.env.test? ? 1 : 12

  # Require email to be present for users
  config.reconfirmable = true

  # Time someone is remembered without asking for credentials
  config.remember_for = 2.weeks

  # Expire password reset tokens after:
  config.reset_password_within = 6.hours

  # Sign out via DELETE request
  config.sign_out_via = :delete

  #
  # GOOGLE OAUTH (SAFE VERSION)
  # These ENV variables must be in your .env file (not in repo)
  #
  config.omniauth :google_oauth2,
                  ENV["GOOGLE_CLIENT_ID"],
                  ENV["GOOGLE_CLIENT_SECRET"],
                  scope: "userinfo.email,userinfo.profile",
                  redirect_uri: "#{ENV['APP_URL']}/users/auth/google_oauth2/callback"
end
