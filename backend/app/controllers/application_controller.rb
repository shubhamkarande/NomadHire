# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Pundit::Authorization

  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  protected

  def current_user
    @current_user ||= warden.authenticate(scope: :user)
  end

  def authenticate_user!
    unless current_user
      render json: { error: 'You need to sign in or sign up before continuing.' }, status: :unauthorized
    end
  end

  private

  def user_not_authorized
    render json: { error: 'You are not authorized to perform this action.' }, status: :forbidden
  end

  def record_not_found
    render json: { error: 'Resource not found.' }, status: :not_found
  end

  def record_invalid(exception)
    render json: { errors: exception.record.errors }, status: :unprocessable_entity
  end

  def render_success(data = {}, status: :ok)
    render json: data, status: status
  end

  def render_error(message, status: :unprocessable_entity)
    render json: { error: message }, status: status
  end

  def render_errors(errors, status: :unprocessable_entity)
    render json: { errors: errors }, status: status
  end
end
