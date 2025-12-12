# frozen_string_literal: true

class Bid < ApplicationRecord
  belongs_to :job
  belongs_to :freelancer, class_name: 'User'

  # Enums
  enum :status, { pending: 0, withdrawn: 1, accepted: 2, declined: 3 }, default: :pending

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :cover_letter, presence: true, length: { minimum: 50, maximum: 5000 }
  validates :estimated_days, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :freelancer_id, uniqueness: { scope: :job_id, message: "has already bid on this job" }
  validate :job_must_be_open, on: :create
  validate :freelancer_cannot_be_client

  # Scopes
  scope :active, -> { where(status: [:pending, :accepted]) }
  scope :for_job, ->(job_id) { where(job_id: job_id) }

  # Methods
  def accept!
    return false unless pending?
    return false unless job.open?

    transaction do
      update!(status: :accepted)
      job.bids.where.not(id: id).pending.update_all(status: :declined)
      job.update!(status: :in_progress)
      create_contract!
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def decline!
    return false unless pending?
    update(status: :declined)
  end

  def withdraw!
    return false unless pending?
    update(status: :withdrawn)
  end

  private

  def create_contract!
    Contract.create!(
      job: job,
      client: job.client,
      freelancer: freelancer,
      total_amount: amount,
      status: :active
    )
  end

  def job_must_be_open
    if job.present? && !job.open?
      errors.add(:job, "is not open for bids")
    end
  end

  def freelancer_cannot_be_client
    if freelancer_id.present? && job.present? && freelancer_id == job.client_id
      errors.add(:freelancer, "cannot bid on their own job")
    end
  end
end
