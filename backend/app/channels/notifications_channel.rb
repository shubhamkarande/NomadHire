# frozen_string_literal: true

class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def mark_read(data)
    notification = current_user.notifications.find_by(id: data['notification_id'])
    notification&.mark_as_read!
  end

  def mark_all_read
    Notification.mark_all_read_for(current_user)
    
    NotificationsChannel.broadcast_to(
      current_user,
      {
        type: 'all_read',
        read_at: Time.current.iso8601
      }
    )
  end
end
