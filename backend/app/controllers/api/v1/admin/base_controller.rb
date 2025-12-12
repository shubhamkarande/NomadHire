# frozen_string_literal: true

module Api
  module V1
    module Admin
      class BaseController < Api::V1::BaseController
        before_action :authorize_admin!

        private

        def authorize_admin!
          unless current_user&.admin?
            render json: { error: 'Admin access required' }, status: :forbidden
          end
        end
      end
    end
  end
end
