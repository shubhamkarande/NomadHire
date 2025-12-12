# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user

  # Validations
  validates :kind, presence: true

  # Scopes
  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  after_create_commit :broadcast_notification

  # Constants
  KINDS = %w[
    new_bid
    bid_accepted
    bid_declined
    milestone_paid
    milestone_released
    new_message
    new_review
    contract_completed
  ].freeze

  validates :kind, inclusion: { in: KINDS }

  # Methods
  def mark_as_read!
    update(read: true) unless read?
  end

  def self.mark_all_read_for(user)
    where(user: user, read: false).update_all(read: true)
  end

  # Notification creation helpers
  def self.notify_new_bid(bid)
    create(
      user: bid.job.client,
      kind: 'new_bid',
      payload: {
        job_id: bid.job_id,
        job_title: bid.job.title,
        bid_id: bid.id,
        freelancer_name: bid.freelancer.name,
        amount: bid.amount.to_f
      }
    )
  end

  def self.notify_bid_accepted(bid)
    create(
      user: bid.freelancer,
      kind: 'bid_accepted',
      payload: {
        job_id: bid.job_id,
        job_title: bid.job.title,
        bid_id: bid.id
      }
    )
  end

  def self.notify_milestone_paid(milestone)
    create(
      user: milestone.freelancer,
      kind: 'milestone_paid',
      payload: {
        milestone_id: milestone.id,
        milestone_title: milestone.title,
        amount: milestone.amount.to_f,
        contract_id: milestone.contract_id
      }
    )
  end

  def self.notify_milestone_released(milestone)
    create(
      user: milestone.freelancer,
      kind: 'milestone_released',
      payload: {
        milestone_id: milestone.id,
        milestone_title: milestone.title,
        amount: milestone.amount.to_f,
        contract_id: milestone.contract_id
      }
    )
  end

  private

  def broadcast_notification
    NotificationsChannel.broadcast_to(
      user,
      {
        type: 'new_notification',
        notification: {
          id: id,
          kind: kind,
          payload: payload,
          read: read,
          created_at: created_at.iso8601
        }
      }
    )
  rescue => e
    Rails.logger.error("Failed to broadcast notification: #{e.message}")
  end
end
