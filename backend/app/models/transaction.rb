# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :milestone
  belongs_to :client, class_name: 'User'

  # Enums
  enum :provider, { stripe: 0, razorpay: 1 }, default: :stripe
  enum :status, { intent: 0, paid: 1, refunded: 2, released: 3, failed: 4 }, default: :intent

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :provider_payment_id, presence: true

  # Scopes
  scope :successful, -> { where(status: [:paid, :released]) }
  scope :for_client, ->(client) { where(client: client) }

  # Methods
  def mark_paid!
    update(status: :paid)
  end

  def mark_released!
    update(status: :released)
  end

  def refund!
    return false unless paid?
    
    # In production, this would call Stripe/Razorpay refund API
    update(status: :refunded)
  end
end
