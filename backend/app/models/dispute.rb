# frozen_string_literal: true

class Dispute < ApplicationRecord
  belongs_to :milestone
  belongs_to :raised_by, class_name: 'User'
  belongs_to :resolved_by, class_name: 'User', optional: true

  has_one :contract, through: :milestone

  enum :status, {
    open: 0,
    under_review: 1,
    resolved_client: 2,
    resolved_freelancer: 3,
    resolved_split: 4,
    cancelled: 5
  }

  validates :reason, presence: true, length: { minimum: 20, maximum: 2000 }
  validates :status, presence: true
  validate :milestone_must_be_paid_or_delivered

  scope :pending, -> { where(status: [:open, :under_review]) }
  scope :resolved, -> { where(status: [:resolved_client, :resolved_freelancer, :resolved_split]) }

  after_create :mark_milestone_disputed
  after_create :notify_parties

  def resolve!(resolution:, resolver:, notes: nil)
    return false unless open? || under_review?
    return false unless valid_resolution?(resolution)

    transaction do
      case resolution
      when 'client'
        update!(status: :resolved_client, resolved_by: resolver, admin_notes: notes, resolved_at: Time.current)
        refund_to_client!
      when 'freelancer'
        update!(status: :resolved_freelancer, resolved_by: resolver, admin_notes: notes, resolved_at: Time.current)
        release_to_freelancer!
      when 'split'
        update!(status: :resolved_split, resolved_by: resolver, admin_notes: notes, resolved_at: Time.current)
        split_funds!
      end

      notify_resolution
    end

    true
  rescue StandardError
    false
  end

  def cancel!
    return false unless open?

    update!(status: :cancelled)
    milestone.update!(status: :paid) if milestone.disputed?
    true
  end

  private

  def milestone_must_be_paid_or_delivered
    return unless milestone.present?

    unless milestone.paid? || milestone.delivered? || milestone.disputed?
      errors.add(:milestone, 'must be in paid or delivered status')
    end
  end

  def mark_milestone_disputed
    milestone.update!(status: :disputed)
  end

  def notify_parties
    contract = milestone.contract
    [contract.client, contract.freelancer].each do |user|
      next if user == raised_by

      Notification.create!(
        user: user,
        kind: 'dispute_opened',
        payload: {
          dispute_id: id,
          milestone_id: milestone_id,
          contract_id: contract.id,
          raised_by_name: raised_by.name
        }
      )
    end
  end

  def notify_resolution
    contract = milestone.contract
    [contract.client, contract.freelancer].each do |user|
      Notification.create!(
        user: user,
        kind: 'dispute_resolved',
        payload: {
          dispute_id: id,
          milestone_id: milestone_id,
          resolution: status
        }
      )
    end
  end

  def valid_resolution?(resolution)
    %w[client freelancer split].include?(resolution)
  end

  def refund_to_client!
    milestone.update!(status: :failed)
    # In production, trigger actual refund via payment provider
    Rails.logger.info "Dispute ##{id}: Refunding #{milestone.amount} to client"
  end

  def release_to_freelancer!
    milestone.update!(status: :released)
    # In production, trigger actual payout to freelancer
    Rails.logger.info "Dispute ##{id}: Releasing #{milestone.amount} to freelancer"
  end

  def split_funds!
    half_amount = milestone.amount / 2.0
    milestone.update!(status: :released)
    # In production, refund half to client, release half to freelancer
    Rails.logger.info "Dispute ##{id}: Splitting #{milestone.amount} - #{half_amount} each"
  end
end
