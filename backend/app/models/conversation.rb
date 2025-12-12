# frozen_string_literal: true

class Conversation < ApplicationRecord
  belongs_to :participant_1, class_name: 'User'
  belongs_to :participant_2, class_name: 'User'

  has_many :messages, dependent: :destroy

  # Validations
  validate :participants_must_be_different
  validate :no_duplicate_conversation, on: :create

  # Scopes
  scope :for_user, ->(user) {
    where('participant_1_id = ? OR participant_2_id = ?', user.id, user.id)
  }
  scope :with_user, ->(user, other_user) {
    where(
      '(participant_1_id = ? AND participant_2_id = ?) OR (participant_1_id = ? AND participant_2_id = ?)',
      user.id, other_user.id, other_user.id, user.id
    )
  }
  scope :recent, -> { order(updated_at: :desc) }

  # Methods
  def other_participant(user)
    user.id == participant_1_id ? participant_2 : participant_1
  end

  def participants
    [participant_1, participant_2]
  end

  def unread_count_for(user)
    messages.where.not(sender: user).where(read_at: nil).count
  end

  def last_message
    messages.order(created_at: :desc).first
  end

  def mark_as_read_by!(user)
    messages.where.not(sender: user).where(read_at: nil).update_all(read_at: Time.current)
  end

  # Class methods
  def self.between(user_1, user_2)
    with_user(user_1, user_2).first_or_create!(
      participant_1: user_1,
      participant_2: user_2
    )
  end

  private

  def participants_must_be_different
    if participant_1_id == participant_2_id
      errors.add(:base, "Cannot have a conversation with yourself")
    end
  end

  def no_duplicate_conversation
    if Conversation.with_user(participant_1, participant_2).exists?
      errors.add(:base, "Conversation already exists")
    end
  end
end
