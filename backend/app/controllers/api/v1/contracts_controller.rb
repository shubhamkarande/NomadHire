# frozen_string_literal: true

module Api
  module V1
    class ContractsController < BaseController
      before_action :set_contract, only: [:show]

      # GET /api/v1/contracts
      def index
        contracts = current_user.contracts.includes(:job, :client, :freelancer, :milestones)
        
        render json: {
          contracts: contracts.map { |c| contract_response(c) }
        }, status: :ok
      end

      # GET /api/v1/contracts/:id
      def show
        authorize_contract_access!
        
        render json: { 
          contract: contract_response(@contract, detailed: true) 
        }, status: :ok
      end

      private

      def set_contract
        @contract = Contract.includes(:job, :client, :freelancer, :milestones).find(params[:id])
      end

      def authorize_contract_access!
        unless current_user.id == @contract.client_id || 
               current_user.id == @contract.freelancer_id ||
               current_user.admin?
          render json: { error: 'Not authorized' }, status: :forbidden
        end
      end

      def contract_response(contract, detailed: false)
        response = {
          id: contract.id,
          job: {
            id: contract.job.id,
            title: contract.job.title
          },
          client: {
            id: contract.client.id,
            name: contract.client.name,
            avatar_url: contract.client.avatar_url
          },
          freelancer: {
            id: contract.freelancer.id,
            name: contract.freelancer.name,
            avatar_url: contract.freelancer.avatar_url
          },
          total_amount: contract.total_amount,
          status: contract.status,
          total_paid: contract.total_paid,
          total_released: contract.total_released,
          created_at: contract.created_at
        }

        if detailed
          response[:milestones] = contract.milestones.map { |m| milestone_response(m) }
        end

        response
      end

      def milestone_response(milestone)
        {
          id: milestone.id,
          title: milestone.title,
          description: milestone.description,
          amount: milestone.amount,
          due_date: milestone.due_date,
          status: milestone.status,
          overdue: milestone.overdue?,
          created_at: milestone.created_at
        }
      end
    end
  end
end
