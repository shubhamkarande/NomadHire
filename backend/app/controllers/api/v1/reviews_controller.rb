# frozen_string_literal: true

module Api
  module V1
    class ReviewsController < BaseController
      before_action :set_contract, only: [:create]

      # GET /api/v1/users/:user_id/reviews
      def index
        user = User.find(params[:user_id])
        reviews = user.reviews_received.includes(:reviewer, :contract).order(created_at: :desc)

        render json: {
          reviews: reviews.map { |r| review_response(r) },
          average_rating: user.rating_cache
        }, status: :ok
      end

      # POST /api/v1/contracts/:contract_id/reviews
      def create
        unless @contract.completed?
          return render json: { error: 'Contract must be completed before reviewing' }, status: :unprocessable_entity
        end

        # Determine who is being reviewed
        reviewed_user = if current_user.id == @contract.client_id
          @contract.freelancer
        elsif current_user.id == @contract.freelancer_id
          @contract.client
        else
          return render json: { error: 'Not authorized' }, status: :forbidden
        end

        review = Review.new(
          reviewer: current_user,
          reviewed_user: reviewed_user,
          contract: @contract,
          rating: review_params[:rating],
          comment: review_params[:comment]
        )

        if review.save
          render json: { review: review_response(review) }, status: :created
        else
          render json: { errors: review.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_contract
        @contract = Contract.find(params[:contract_id])
      end

      def review_params
        params.require(:review).permit(:rating, :comment)
      end

      def review_response(review)
        {
          id: review.id,
          rating: review.rating,
          comment: review.comment,
          reviewer: {
            id: review.reviewer.id,
            name: review.reviewer.name,
            avatar_url: review.reviewer.avatar_url
          },
          contract_id: review.contract_id,
          created_at: review.created_at
        }
      end
    end
  end
end
