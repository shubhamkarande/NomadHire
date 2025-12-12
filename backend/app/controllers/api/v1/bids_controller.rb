# frozen_string_literal: true

module Api
  module V1
    class BidsController < BaseController
      before_action :set_job, only: [:index, :create]
      before_action :set_bid, only: [:show, :accept, :decline, :withdraw]

      # GET /api/v1/jobs/:job_id/bids
      def index
        bids = @job.bids.includes(:freelancer)

        # Clients see all bids, freelancers see only their own
        unless current_user.id == @job.client_id || current_user.admin?
          bids = bids.where(freelancer: current_user)
        end

        render json: {
          bids: bids.map { |b| bid_response(b) }
        }, status: :ok
      end

      # GET /api/v1/bids/:id
      def show
        authorize_bid_access!
        render json: { bid: bid_response(@bid, detailed: true) }, status: :ok
      end

      # POST /api/v1/jobs/:job_id/bids
      def create
        unless current_user.can_bid?
          return render json: { error: 'Only freelancers can place bids' }, status: :forbidden
        end

        bid = @job.bids.build(bid_params)
        bid.freelancer = current_user

        if bid.save
          # Notify job owner
          Notification.notify_new_bid(bid)
          render json: { bid: bid_response(bid) }, status: :created
        else
          render json: { errors: bid.errors }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/bids/:id/accept
      def accept
        unless current_user.id == @bid.job.client_id
          return render json: { error: 'Only the job owner can accept bids' }, status: :forbidden
        end

        if @bid.accept!
          Notification.notify_bid_accepted(@bid)
          contract = @bid.job.contract
          render json: { 
            message: 'Bid accepted successfully',
            contract: contract_response(contract)
          }, status: :ok
        else
          render json: { error: 'Could not accept bid' }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/bids/:id/decline
      def decline
        unless current_user.id == @bid.job.client_id
          return render json: { error: 'Only the job owner can decline bids' }, status: :forbidden
        end

        if @bid.decline!
          render json: { message: 'Bid declined successfully' }, status: :ok
        else
          render json: { error: 'Could not decline bid' }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/bids/:id/withdraw
      def withdraw
        unless current_user.id == @bid.freelancer_id
          return render json: { error: 'Only the bid owner can withdraw' }, status: :forbidden
        end

        if @bid.withdraw!
          render json: { message: 'Bid withdrawn successfully' }, status: :ok
        else
          render json: { error: 'Could not withdraw bid' }, status: :unprocessable_entity
        end
      end

      private

      def set_job
        @job = Job.find(params[:job_id])
      end

      def set_bid
        @bid = Bid.includes(:job, :freelancer).find(params[:id])
      end

      def bid_params
        params.require(:bid).permit(:amount, :cover_letter, :estimated_days)
      end

      def authorize_bid_access!
        unless current_user.id == @bid.freelancer_id || 
               current_user.id == @bid.job.client_id || 
               current_user.admin?
          render json: { error: 'Not authorized' }, status: :forbidden
        end
      end

      def bid_response(bid, detailed: false)
        response = {
          id: bid.id,
          amount: bid.amount,
          cover_letter: detailed ? bid.cover_letter : bid.cover_letter.truncate(200),
          estimated_days: bid.estimated_days,
          status: bid.status,
          freelancer: {
            id: bid.freelancer.id,
            name: bid.freelancer.name,
            avatar_url: bid.freelancer.avatar_url,
            rating_cache: bid.freelancer.rating_cache
          },
          job_id: bid.job_id,
          created_at: bid.created_at
        }

        if detailed
          response[:job] = {
            id: bid.job.id,
            title: bid.job.title
          }
        end

        response
      end

      def contract_response(contract)
        {
          id: contract.id,
          job_id: contract.job_id,
          client_id: contract.client_id,
          freelancer_id: contract.freelancer_id,
          total_amount: contract.total_amount,
          status: contract.status
        }
      end
    end
  end
end
