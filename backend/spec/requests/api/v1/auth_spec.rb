# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Auth', type: :request do
  describe 'POST /api/v1/auth/sign_up' do
    let(:valid_params) do
      {
        user: {
          name: 'Test User',
          email: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          role: 'freelancer'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post '/api/v1/auth/sign_up', params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'returns a token' do
        post '/api/v1/auth/sign_up', params: valid_params
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to have_key('token')
      end

      it 'returns user data' do
        post '/api/v1/auth/sign_up', params: valid_params
        body = JSON.parse(response.body)
        expect(body['user']['email']).to eq('test@example.com')
        expect(body['user']['name']).to eq('Test User')
      end
    end

    context 'with invalid parameters' do
      it 'returns error for missing name' do
        params = valid_params.deep_dup
        params[:user][:name] = ''
        
        post '/api/v1/auth/sign_up', params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error for duplicate email' do
        create(:user, email: 'test@example.com')
        
        post '/api/v1/auth/sign_up', params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error for short password' do
        params = valid_params.deep_dup
        params[:user][:password] = '123'
        params[:user][:password_confirmation] = '123'
        
        post '/api/v1/auth/sign_up', params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST /api/v1/auth/sign_in' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns a token' do
        post '/api/v1/auth/sign_in', params: {
          user: { email: 'test@example.com', password: 'password123' }
        }
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key('token')
      end

      it 'returns user data' do
        post '/api/v1/auth/sign_in', params: {
          user: { email: 'test@example.com', password: 'password123' }
        }
        
        body = JSON.parse(response.body)
        expect(body['user']['email']).to eq('test@example.com')
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized for wrong password' do
        post '/api/v1/auth/sign_in', params: {
          user: { email: 'test@example.com', password: 'wrongpassword' }
        }
        
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns unauthorized for non-existent email' do
        post '/api/v1/auth/sign_in', params: {
          user: { email: 'nonexistent@example.com', password: 'password123' }
        }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/auth/me' do
    let(:user) { create(:user) }

    context 'with valid token' do
      it 'returns current user' do
        token = generate_jwt_token(user)
        
        get '/api/v1/auth/me', headers: { 'Authorization' => "Bearer #{token}" }
        
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['user']['id']).to eq(user.id)
      end
    end

    context 'without token' do
      it 'returns unauthorized' do
        get '/api/v1/auth/me'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # Helper method to generate JWT token for tests
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
