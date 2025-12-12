# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :conversation, touch: true
  belongs_to :sender, class_name: 'User'

  has_many_attached :attachments

  # Validations
  validates :body, presence: true, length: { maximum: 10000 }
  validate :sender_is_participant

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :chronological, -> { order(created_at: :asc) }

  # Callbacks
  after_create_commit :broadcast_message
  after_create_commit :send_notification

  # Methods
  def read?
    read_at.present?
  end

  def mark_as_read!
    update(read_at: Time.current) unless read?
  end

  def recipient
    conversation.other_participant(sender)
  end

  private

  def sender_is_participant
    unless conversation&.participants&.include?(sender)
      errors.add(:sender, "must be a participant in the conversation")
    end
  end

  def broadcast_message
    # Broadcast via ActionCable
    ChatChannel.broadcast_to(
      conversation,
      {
        type: 'new_message',
        message: {
          id: id,
          body: body,
          sender_id: sender_id,
          sender_name: sender.name,
          created_at: created_at.iso8601,
          read_at: read_at&.iso8601
        }
      }
    )
  rescue => e
    Rails.logger.error("Failed to broadcast message: #{e.message}")
  end

  def send_notification
    Notification.create(
      user: recipient,
      kind: 'new_message',
      payload: {
        conversation_id: conversation_id,
        sender_id: sender_id,
        sender_name: sender.name,
        preview: body.truncate(50)
      }
    )
  end
end
