# frozen_string_literal: true

class Job < ApplicationRecord
  belongs_to :client, class_name: 'User'

  has_many :job_skills, dependent: :destroy
  has_many :skills, through: :job_skills
  has_many :bids, dependent: :destroy
  has_one :contract, dependent: :destroy

  has_many_attached :attachments

  # Enums
  enum :budget_type, { fixed: 0, hourly: 1 }, default: :fixed
  enum :status, { open: 0, in_progress: 1, completed: 2, closed: 3, cancelled: 4 }, default: :open

  # Validations
  validates :title, presence: true, length: { minimum: 10, maximum: 200 }
  validates :description, presence: true, length: { minimum: 50, maximum: 10000 }
  validates :budget_min, presence: true, numericality: { greater_than: 0 }
  validates :budget_max, numericality: { greater_than_or_equal_to: :budget_min }, allow_nil: true
  validates :deadline, presence: true
  validate :deadline_must_be_future, on: :create

  # Scopes
  scope :active, -> { where(status: :open) }
  scope :by_skill, ->(skill_names) { 
    joins(:skills).where(skills: { slug: skill_names }) if skill_names.present?
  }
  scope :by_budget_range, ->(min, max) {
    where('budget_min >= ? AND budget_max <= ?', min, max) if min.present? && max.present?
  }
  scope :search, ->(query) {
    where('title ILIKE ? OR description ILIKE ?', "%#{query}%", "%#{query}%") if query.present?
  }
  scope :recent, -> { order(created_at: :desc) }

  # Methods
  def budget_range
    return "#{budget_min}" if budget_max.nil? || budget_min == budget_max
    "#{budget_min} - #{budget_max}"
  end

  def accepted_bid
    bids.accepted.first
  end

  def has_accepted_bid?
    bids.accepted.exists?
  end

  private

  def deadline_must_be_future
    if deadline.present? && deadline < Date.current
      errors.add(:deadline, "must be in the future")
    end
  end
end
