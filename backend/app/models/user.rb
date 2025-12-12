# frozen_string_literal: true

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  # Enums
  enum :role, { freelancer: 0, client: 1, admin: 2 }, default: :freelancer

  # Associations
  has_many :user_skills, dependent: :destroy
  has_many :skills, through: :user_skills

  # Client associations
  has_many :posted_jobs, class_name: 'Job', foreign_key: 'client_id', dependent: :destroy
  has_many :client_contracts, class_name: 'Contract', foreign_key: 'client_id', dependent: :destroy
  has_many :client_transactions, class_name: 'Transaction', foreign_key: 'client_id', dependent: :nullify

  # Freelancer associations
  has_many :bids, foreign_key: 'freelancer_id', dependent: :destroy
  has_many :freelancer_contracts, class_name: 'Contract', foreign_key: 'freelancer_id', dependent: :destroy

  # Chat associations
  has_many :conversations_as_participant_1, class_name: 'Conversation', foreign_key: 'participant_1_id', dependent: :destroy
  has_many :conversations_as_participant_2, class_name: 'Conversation', foreign_key: 'participant_2_id', dependent: :destroy
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id', dependent: :destroy

  # Notifications
  has_many :notifications, dependent: :destroy

  # Reviews
  has_many :reviews_given, class_name: 'Review', foreign_key: 'reviewer_id', dependent: :destroy
  has_many :reviews_received, class_name: 'Review', foreign_key: 'reviewed_user_id', dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :bio, length: { maximum: 2000 }, allow_blank: true
  validates :hourly_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :location, length: { maximum: 200 }, allow_blank: true

  # Callbacks
  before_validation :set_default_role, on: :create

  # Instance methods
  def conversations
    Conversation.where('participant_1_id = ? OR participant_2_id = ?', id, id)
  end

  def contracts
    Contract.where('client_id = ? OR freelancer_id = ?', id, id)
  end

  def can_post_jobs?
    client? || admin?
  end

  def can_bid?
    freelancer?
  end

  def update_rating_cache!
    avg_rating = reviews_received.average(:rating)&.round(2) || 0.0
    update_column(:rating_cache, avg_rating)
  end

  # JWT payload
  def jwt_payload
    {
      'user_id' => id,
      'role' => role,
      'email' => email
    }
  end

  private

  def set_default_role
    self.role ||= :freelancer
  end
end
