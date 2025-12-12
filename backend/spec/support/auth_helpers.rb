# frozen_string_literal: true

# Shared context for authenticated requests
RSpec.shared_context 'authenticated user' do
  def auth_headers(user)
    token = generate_jwt_token(user)
    { 'Authorization' => "Bearer #{token}" }
  end

  def generate_jwt_token(user)
    payload = {
      user_id: user.id,
      email: user.email,
      role: user.role,
      jti: SecureRandom.uuid,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(
      payload,
      ENV.fetch('DEVISE_JWT_SECRET') { Rails.application.credentials.devise_jwt_secret || Rails.application.secret_key_base },
      'HS256'
    )
  end
end

RSpec.configure do |config|
  config.include_context 'authenticated user', type: :request
end
