# frozen_string_literal: true

# Stripe configuration
# Uses test keys only - NEVER use production keys in this app

Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY", nil)

# Set API version for consistency
Stripe.api_version = "2023-10-16"

# Enable logging in development
if Rails.env.development?
  Stripe.log_level = Stripe::LEVEL_INFO
end
