# frozen_string_literal: true

# Razorpay configuration
# Uses sandbox keys only - NEVER use production keys in this app

module RazorpayConfig
  class << self
    def client
      @client ||= Razorpay::Client.new(
        ENV.fetch("RAZORPAY_KEY_ID", nil),
        ENV.fetch("RAZORPAY_KEY_SECRET", nil)
      )
    end

    def configured?
      ENV["RAZORPAY_KEY_ID"].present? && ENV["RAZORPAY_KEY_SECRET"].present?
    end
  end
end
