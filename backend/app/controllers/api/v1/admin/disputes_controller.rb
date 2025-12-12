# frozen_string_literal: true

module Api
  module V1
    module Admin
      class DisputesController < BaseController
        before_action :set_dispute

        # GET /api/v1/admin/disputes
        def index
          disputes = Dispute.includes(:milestone, :raised_by, milestone: :contract)
          disputes = disputes.pending if params[:status] == 'pending'
          disputes = disputes.resolved if params[:status] == 'resolved'
          disputes = disputes.order(created_at: :desc)

          @disputes = paginate(disputes)
          render json: {
            disputes: @disputes.map { |d| admin_dispute_json(d) },
            meta: pagination_meta(@disputes),
            stats: dispute_stats
          }
        end

        # GET /api/v1/admin/disputes/:id
        def show
          render json: { dispute: admin_dispute_json(@dispute, detailed: true) }
        end

        # POST /api/v1/admin/disputes/:id/resolve
        def resolve
          resolution = params[:resolution] # 'client', 'freelancer', or 'split'
          notes = params[:admin_notes]

          unless %w[client freelancer split].include?(resolution)
            return render_error('Invalid resolution type', :unprocessable_entity)
          end

          if @dispute.resolve!(resolution: resolution, resolver: current_user, notes: notes)
            render json: { 
              message: "Dispute resolved in favor of #{resolution}",
              dispute: admin_dispute_json(@dispute)
            }
          else
            render_error('Failed to resolve dispute', :unprocessable_entity)
          end
        end

        # PATCH /api/v1/admin/disputes/:id
        def update
          if @dispute.update(admin_dispute_params)
            render json: { dispute: admin_dispute_json(@dispute) }
          else
            render_error(@dispute.errors.full_messages.join(', '), :unprocessable_entity)
          end
        end

        private

        def set_dispute
          @dispute = Dispute.find(params[:id]) if params[:id].present?
        end

        def admin_dispute_params
          params.require(:dispute).permit(:status, :admin_notes)
        end

        def admin_dispute_json(dispute, detailed: false)
          contract = dispute.milestone.contract

          data = {
            id: dispute.id,
            reason: dispute.reason,
            evidence: dispute.evidence,
            status: dispute.status,
            admin_notes: dispute.admin_notes,
            raised_by: user_summary(dispute.raised_by),
            resolved_by: dispute.resolved_by ? user_summary(dispute.resolved_by) : nil,
            milestone: {
              id: dispute.milestone.id,
              title: dispute.milestone.title,
              amount: dispute.milestone.amount,
              status: dispute.milestone.status
            },
            contract: {
              id: contract.id,
              job_title: contract.job.title,
              client: user_summary(contract.client),
              freelancer: user_summary(contract.freelancer)
            },
            created_at: dispute.created_at,
            resolved_at: dispute.resolved_at
          }

          data
        end

        def user_summary(user)
          {
            id: user.id,
            name: user.name,
            email: user.email
          }
        end

        def dispute_stats
          {
            total: Dispute.count,
            open: Dispute.open.count,
            under_review: Dispute.under_review.count,
            resolved: Dispute.resolved.count
          }
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
end
