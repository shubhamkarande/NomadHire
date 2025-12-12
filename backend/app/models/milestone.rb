# frozen_string_literal: true

class Milestone < ApplicationRecord
  belongs_to :contract

  has_many :transactions, dependent: :destroy
  has_many_attached :deliverables

  # Enums
  enum :status, { 
    pending: 0, 
    paid: 1, 
    delivered: 2, 
    released: 3, 
    failed: 4,
    disputed: 5
  }, default: :pending

  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 200 }
  validates :description, length: { maximum: 5000 }, allow_blank: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :due_date, presence: true

  # Scopes
  scope :upcoming, -> { where(status: [:pending, :paid]).order(due_date: :asc) }
  scope :active, -> { where(status: [:pending, :paid, :delivered]) }

  # Delegates
  delegate :client, :freelancer, to: :contract

  # Methods
  def pay!(provider: 'stripe', payment_intent_id:)
    return false unless pending?
    
    transaction do
      update!(
        status: :paid,
        payment_transaction_id: payment_intent_id
      )
      
      Transaction.create!(
        milestone: self,
        client: contract.client,
        amount: amount,
        provider: provider,
        provider_payment_id: payment_intent_id,
        status: :paid
      )
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Milestone payment failed: #{e.message}")
    false
  end

  def mark_delivered!
    return false unless paid?
    update(status: :delivered)
  end

  def release!
    return false unless delivered? || paid?
    
    transaction do
      update!(status: :released)
      
      # Update the transaction status
      transactions.paid.update_all(status: :released)
      
      # Check if contract is complete
      contract.mark_complete! if contract.all_milestones_released?
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def overdue?
    due_date < Date.current && !released? && !failed?
  end
end
