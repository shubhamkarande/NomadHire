# frozen_string_literal: true

module Api
  module V1
    class MilestonesController < BaseController
      before_action :set_contract, only: [:create]
      before_action :set_milestone, only: [:show, :pay, :complete, :release]

      # POST /api/v1/contracts/:contract_id/milestones
      def create
        unless current_user.id == @contract.client_id
          return render json: { error: 'Only the client can create milestones' }, status: :forbidden
        end

        milestone = @contract.milestones.build(milestone_params)

        if milestone.save
          render json: { milestone: milestone_response(milestone) }, status: :created
        else
          render json: { errors: milestone.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/milestones/:id
      def show
        authorize_milestone_access!
        render json: { milestone: milestone_response(@milestone, detailed: true) }, status: :ok
      end

      # POST /api/v1/milestones/:id/pay
      def pay
        unless current_user.id == @milestone.contract.client_id
          return render json: { error: 'Only the client can pay milestones' }, status: :forbidden
        end

        unless @milestone.pending?
          return render json: { error: 'Milestone is not in pending status' }, status: :unprocessable_entity
        end

        provider = params[:provider] || 'stripe'
        
        begin
          result = create_payment_intent(provider)
          render json: result, status: :ok
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/milestones/:id/complete
      def complete
        unless current_user.id == @milestone.contract.freelancer_id
          return render json: { error: 'Only the freelancer can mark milestones as complete' }, status: :forbidden
        end

        if @milestone.mark_delivered!
          render json: { 
            message: 'Milestone marked as delivered',
            milestone: milestone_response(@milestone)
          }, status: :ok
        else
          render json: { error: 'Could not mark milestone as complete' }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/milestones/:id/release
      def release
        unless current_user.id == @milestone.contract.client_id
          return render json: { error: 'Only the client can release milestone funds' }, status: :forbidden
        end

        if @milestone.release!
          Notification.notify_milestone_released(@milestone)
          render json: { 
            message: 'Funds released successfully',
            milestone: milestone_response(@milestone)
          }, status: :ok
        else
          render json: { error: 'Could not release funds' }, status: :unprocessable_entity
        end
      end

      private

      def set_contract
        @contract = Contract.find(params[:contract_id])
      end

      def set_milestone
        @milestone = Milestone.includes(:contract).find(params[:id])
      end

      def milestone_params
        params.require(:milestone).permit(:title, :description, :amount, :due_date)
      end

      def authorize_milestone_access!
        unless current_user.id == @milestone.contract.client_id ||
               current_user.id == @milestone.contract.freelancer_id ||
               current_user.admin?
          render json: { error: 'Not authorized' }, status: :forbidden
        end
      end

      def create_payment_intent(provider)
        case provider
        when 'stripe'
          create_stripe_intent
        when 'razorpay'
          create_razorpay_order
        else
          raise "Unknown payment provider: #{provider}"
        end
      end

      def create_stripe_intent
        # Create Stripe PaymentIntent (TEST MODE ONLY)
        intent = Stripe::PaymentIntent.create(
          amount: (@milestone.amount * 100).to_i, # Convert to cents
          currency: 'usd',
          metadata: {
            milestone_id: @milestone.id,
            contract_id: @milestone.contract_id,
            client_id: current_user.id
          },
          description: "Payment for milestone: #{@milestone.title}"
        )

        {
          provider: 'stripe',
          client_secret: intent.client_secret,
          payment_intent_id: intent.id,
          amount: @milestone.amount
        }
      end

      def create_razorpay_order
        # Create Razorpay Order (SANDBOX MODE ONLY)
        raise "Razorpay not configured" unless RazorpayConfig.configured?

        order = RazorpayConfig.client.order.create(
          amount: (@milestone.amount * 100).to_i, # Convert to paise
          currency: 'INR',
          notes: {
            milestone_id: @milestone.id,
            contract_id: @milestone.contract_id,
            client_id: current_user.id
          }
        )

        {
          provider: 'razorpay',
          order_id: order.id,
          amount: @milestone.amount,
          key_id: ENV['RAZORPAY_KEY_ID']
        }
      end

      def milestone_response(milestone, detailed: false)
        response = {
          id: milestone.id,
          title: milestone.title,
          description: milestone.description,
          amount: milestone.amount,
          due_date: milestone.due_date,
          status: milestone.status,
          overdue: milestone.overdue?,
          created_at: milestone.created_at
        }

        if detailed
          response[:contract] = {
            id: milestone.contract.id,
            job_title: milestone.contract.job.title,
            client_name: milestone.contract.client.name,
            freelancer_name: milestone.contract.freelancer.name
          }
          response[:transactions] = milestone.transactions.map do |t|
            {
              id: t.id,
              amount: t.amount,
              provider: t.provider,
              status: t.status,
              created_at: t.created_at
            }
          end
        end

        response
      end
    end
  end
end
