# frozen_string_literal: true

class Review < ApplicationRecord
  belongs_to :reviewer, class_name: 'User'
  belongs_to :reviewed_user, class_name: 'User'
  belongs_to :contract

  # Validations
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, length: { maximum: 2000 }, allow_blank: true
  validates :reviewer_id, uniqueness: { 
    scope: :contract_id, 
    message: "has already reviewed this contract" 
  }
  validate :reviewer_is_contract_party
  validate :contract_must_be_completed

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(reviewed_user: user) }

  # Callbacks
  after_create :update_user_rating
  after_create :create_notification

  private

  def reviewer_is_contract_party
    unless [contract.client_id, contract.freelancer_id].include?(reviewer_id)
      errors.add(:reviewer, "must be part of the contract")
    end
    
    if reviewer_id == reviewed_user_id
      errors.add(:reviewer, "cannot review themselves")
    end
  end

  def contract_must_be_completed
    unless contract.completed?
      errors.add(:contract, "must be completed before reviewing")
    end
  end

  def update_user_rating
    reviewed_user.update_rating_cache!
  end

  def create_notification
    Notification.create(
      user: reviewed_user,
      kind: 'new_review',
      payload: {
        review_id: id,
        reviewer_name: reviewer.name,
        rating: rating,
        contract_id: contract_id
      }
    )
  end
end
