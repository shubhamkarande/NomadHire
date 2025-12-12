# frozen_string_literal: true

module Api
  module V1
    class DisputesController < BaseController
      before_action :authenticate_user!
      before_action :set_milestone, only: [:create]
      before_action :set_dispute, only: [:show, :cancel]

      # GET /api/v1/disputes
      def index
        disputes = current_user.admin? ? Dispute.all : user_disputes
        disputes = disputes.includes(:milestone, :raised_by).order(created_at: :desc)
        
        @disputes = paginate(disputes)
        render json: {
          disputes: @disputes.map { |d| dispute_json(d) },
          meta: pagination_meta(@disputes)
        }
      end

      # GET /api/v1/disputes/:id
      def show
        authorize_dispute_access!
        render json: { dispute: dispute_json(@dispute, detailed: true) }
      end

      # POST /api/v1/milestones/:milestone_id/disputes
      def create
        authorize_dispute_creation!

        @dispute = Dispute.new(dispute_params)
        @dispute.milestone = @milestone
        @dispute.raised_by = current_user

        if @dispute.save
          render json: { dispute: dispute_json(@dispute) }, status: :created
        else
          render_error(@dispute.errors.full_messages.join(', '), :unprocessable_entity)
        end
      end

      # POST /api/v1/disputes/:id/cancel
      def cancel
        unless @dispute.raised_by == current_user
          return render_error('Only the dispute raiser can cancel', :forbidden)
        end

        if @dispute.cancel!
          render json: { message: 'Dispute cancelled', dispute: dispute_json(@dispute) }
        else
          render_error('Cannot cancel this dispute', :unprocessable_entity)
        end
      end

      private

      def set_milestone
        @milestone = Milestone.find(params[:milestone_id])
      end

      def set_dispute
        @dispute = Dispute.find(params[:id])
      end

      def dispute_params
        params.require(:dispute).permit(:reason, :evidence)
      end

      def authorize_dispute_access!
        contract = @dispute.milestone.contract
        unless current_user.admin? || contract.client == current_user || contract.freelancer == current_user
          render_error('Not authorized', :forbidden)
        end
      end

      def authorize_dispute_creation!
        contract = @milestone.contract
        unless contract.client == current_user || contract.freelancer == current_user
          render_error('Not authorized to dispute this milestone', :forbidden)
        end

        unless @milestone.paid? || @milestone.delivered?
          render_error('Milestone must be paid or delivered to dispute', :unprocessable_entity)
        end
      end

      def user_disputes
        user_contract_ids = Contract.where('client_id = ? OR freelancer_id = ?', current_user.id, current_user.id).pluck(:id)
        milestone_ids = Milestone.where(contract_id: user_contract_ids).pluck(:id)
        Dispute.where(milestone_id: milestone_ids)
      end

      def dispute_json(dispute, detailed: false)
        data = {
          id: dispute.id,
          reason: dispute.reason,
          status: dispute.status,
          raised_by: {
            id: dispute.raised_by.id,
            name: dispute.raised_by.name
          },
          milestone: {
            id: dispute.milestone.id,
            title: dispute.milestone.title,
            amount: dispute.milestone.amount
          },
          created_at: dispute.created_at,
          resolved_at: dispute.resolved_at
        }

        if detailed
          data[:evidence] = dispute.evidence
          data[:admin_notes] = dispute.admin_notes if current_user.admin?
          data[:resolved_by] = dispute.resolved_by&.name
        end

        data
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          per_page: collection.limit_value,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end
    end
  end
end
