# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # Get token from query params (WebSocket connections can't use headers)
      token = request.params[:token]

      return reject_unauthorized_connection unless token

      begin
        decoded = JWT.decode(
          token,
          ENV.fetch('DEVISE_JWT_SECRET') { Rails.application.credentials.devise_jwt_secret || Rails.application.secret_key_base },
          true,
          { algorithm: 'HS256' }
        )

        user_id = decoded[0]['user_id']
        jti = decoded[0]['jti']

        # Check if token is revoked
        if JwtDenylist.exists?(jti: jti)
          return reject_unauthorized_connection
        end

        user = User.find_by(id: user_id)
        user || reject_unauthorized_connection
      rescue JWT::DecodeError, JWT::ExpiredSignature
        reject_unauthorized_connection
      end
    end
  end
end
