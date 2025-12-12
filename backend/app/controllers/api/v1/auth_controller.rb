# frozen_string_literal: true

module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_user!, only: [:sign_up, :sign_in]

      # POST /api/v1/auth/sign_up
      def sign_up
        user = User.new(sign_up_params)

        if user.save
          token = generate_jwt_token(user)
          render json: {
            user: user_response(user),
            token: token
          }, status: :created
        else
          render json: { errors: user.errors }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/auth/sign_in
      def sign_in
        user = User.find_by(email: sign_in_params[:email]&.downcase)

        if user&.valid_password?(sign_in_params[:password])
          token = generate_jwt_token(user)
          render json: {
            user: user_response(user),
            token: token
          }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      # DELETE /api/v1/auth/sign_out
      def sign_out
        # JWT is stateless, but we can add the token to denylist
        if request.headers['Authorization'].present?
          token = request.headers['Authorization'].split(' ').last
          begin
            decoded = JWT.decode(
              token,
              ENV.fetch('DEVISE_JWT_SECRET') { Rails.application.credentials.devise_jwt_secret || Rails.application.secret_key_base },
              true,
              { algorithm: 'HS256' }
            )
            jti = decoded[0]['jti']
            exp = Time.at(decoded[0]['exp'])
            JwtDenylist.create(jti: jti, exp: exp)
          rescue JWT::DecodeError
            # Token is invalid, but we still return success
          end
        end

        render json: { message: 'Signed out successfully' }, status: :ok
      end

      # GET /api/v1/auth/me
      def me
        render json: { user: user_response(current_user, full: true) }, status: :ok
      end

      private

      def sign_up_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
      end

      def sign_in_params
        params.require(:user).permit(:email, :password)
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

      def user_response(user, full: false)
        response = {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role
        }

        if full
          response.merge!(
            bio: user.bio,
            skills: user.skills.pluck(:name),
            hourly_rate: user.hourly_rate,
            location: user.location,
            avatar_url: user.avatar_url,
            rating_cache: user.rating_cache,
            created_at: user.created_at
          )
        end

        response
      end
    end
  end
end
