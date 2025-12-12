# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      # Skip authentication by default for public endpoints
      # Individual controllers should call authenticate_user! as needed
      skip_before_action :authenticate_user!, only: []

      protected

      def pagination_params
        {
          page: params[:page] || 1,
          per_page: [params[:per_page].to_i, 50].min.clamp(1, 50)
        }
      end

      def paginate(collection)
        page = pagination_params[:page].to_i
        per_page = pagination_params[:per_page]

        total_count = collection.count
        total_pages = (total_count.to_f / per_page).ceil

        {
          data: collection.offset((page - 1) * per_page).limit(per_page),
          meta: {
            current_page: page,
            per_page: per_page,
            total_pages: total_pages,
            total_count: total_count
          }
        }
      end
    end
  end
end
