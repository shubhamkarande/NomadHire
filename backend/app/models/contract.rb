# frozen_string_literal: true

class Contract < ApplicationRecord
  belongs_to :job
  belongs_to :client, class_name: 'User'
  belongs_to :freelancer, class_name: 'User'

  has_many :milestones, dependent: :destroy
  has_many :reviews, dependent: :destroy

  # Enums
  enum :status, { active: 0, completed: 1, cancelled: 2, disputed: 3 }, default: :active

  # Validations
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validate :client_owns_job
  validate :freelancer_has_accepted_bid

  # Scopes
  scope :for_user, ->(user) {
    where('client_id = ? OR freelancer_id = ?', user.id, user.id)
  }

  # Methods
  def other_party(user)
    user.id == client_id ? freelancer : client
  end

  def all_milestones_released?
    milestones.any? && milestones.all? { |m| m.released? }
  end

  def mark_complete!
    return false unless active?
    return false unless all_milestones_released?
    
    update(status: :completed)
    job.update(status: :completed)
    true
  end

  def total_paid
    milestones.where(status: [:paid, :delivered, :released]).sum(:amount)
  end

  def total_released
    milestones.released.sum(:amount)
  end

  private

  def client_owns_job
    if job.present? && job.client_id != client_id
      errors.add(:client, "must own the job")
    end
  end

  def freelancer_has_accepted_bid
    if job.present? && freelancer.present?
      unless job.bids.accepted.exists?(freelancer: freelancer)
        errors.add(:freelancer, "must have an accepted bid")
      end
    end
  end
end
