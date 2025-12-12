# frozen_string_literal: true

module Api
  module V1
    class WebhooksController < BaseController
      skip_before_action :authenticate_user!

      # POST /api/v1/webhooks/stripe
      def stripe
        payload = request.body.read
        sig_header = request.env['HTTP_STRIPE_SIGNATURE']
        endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

        begin
          event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
        rescue JSON::ParserError => e
          Rails.logger.error("Stripe webhook JSON parse error: #{e.message}")
          return render json: { error: 'Invalid payload' }, status: :bad_request
        rescue Stripe::SignatureVerificationError => e
          Rails.logger.error("Stripe webhook signature error: #{e.message}")
          return render json: { error: 'Invalid signature' }, status: :bad_request
        end

        # Handle the event
        case event.type
        when 'payment_intent.succeeded'
          handle_payment_intent_succeeded(event.data.object)
        when 'payment_intent.payment_failed'
          handle_payment_intent_failed(event.data.object)
        else
          Rails.logger.info("Unhandled Stripe event type: #{event.type}")
        end

        render json: { received: true }, status: :ok
      end

      # POST /api/v1/webhooks/razorpay
      def razorpay
        payload = request.body.read
        signature = request.env['HTTP_X_RAZORPAY_SIGNATURE']
        secret = ENV['RAZORPAY_KEY_SECRET']

        # Verify webhook signature
        expected_signature = OpenSSL::HMAC.hexdigest('sha256', secret, payload)
        
        unless Rack::Utils.secure_compare(expected_signature, signature.to_s)
          Rails.logger.error("Razorpay webhook signature mismatch")
          return render json: { error: 'Invalid signature' }, status: :bad_request
        end

        event = JSON.parse(payload)
        
        case event['event']
        when 'payment.captured'
          handle_razorpay_payment_captured(event['payload']['payment']['entity'])
        when 'payment.failed'
          handle_razorpay_payment_failed(event['payload']['payment']['entity'])
        else
          Rails.logger.info("Unhandled Razorpay event: #{event['event']}")
        end

        render json: { received: true }, status: :ok
      rescue JSON::ParserError => e
        Rails.logger.error("Razorpay webhook JSON parse error: #{e.message}")
        render json: { error: 'Invalid payload' }, status: :bad_request
      end

      private

      def handle_payment_intent_succeeded(payment_intent)
        milestone_id = payment_intent.metadata.milestone_id
        milestone = Milestone.find_by(id: milestone_id)
        
        return unless milestone

        milestone.pay!(
          provider: 'stripe',
          payment_intent_id: payment_intent.id
        )

        Notification.notify_milestone_paid(milestone)
        Rails.logger.info("Stripe payment succeeded for milestone #{milestone_id}")
      end

      def handle_payment_intent_failed(payment_intent)
        milestone_id = payment_intent.metadata.milestone_id
        milestone = Milestone.find_by(id: milestone_id)
        
        return unless milestone
        return unless milestone.pending?

        milestone.update(status: :failed)
        Rails.logger.info("Stripe payment failed for milestone #{milestone_id}")
      end

      def handle_razorpay_payment_captured(payment)
        milestone_id = payment.dig('notes', 'milestone_id')
        milestone = Milestone.find_by(id: milestone_id)
        
        return unless milestone

        milestone.pay!(
          provider: 'razorpay',
          payment_intent_id: payment['id']
        )

        Notification.notify_milestone_paid(milestone)
        Rails.logger.info("Razorpay payment captured for milestone #{milestone_id}")
      end

      def handle_razorpay_payment_failed(payment)
        milestone_id = payment.dig('notes', 'milestone_id')
        milestone = Milestone.find_by(id: milestone_id)
        
        return unless milestone
        return unless milestone.pending?

        milestone.update(status: :failed)
        Rails.logger.info("Razorpay payment failed for milestone #{milestone_id}")
      end
    end
  end
end
