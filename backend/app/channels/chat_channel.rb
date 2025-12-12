# frozen_string_literal: true

class ChatChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find(params[:conversation_id])
    
    # Verify user is participant
    unless conversation.participants.include?(current_user)
      reject
      return
    end

    stream_for conversation
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    conversation = Conversation.find(params[:conversation_id])
    
    # Verify user is participant
    return unless conversation.participants.include?(current_user)

    message = conversation.messages.create!(
      sender: current_user,
      body: data['body']
    )

    # Broadcasting is handled by Message model after_create_commit callback
  end

  def typing
    conversation = Conversation.find(params[:conversation_id])
    
    # Verify user is participant
    return unless conversation.participants.include?(current_user)

    ChatChannel.broadcast_to(
      conversation,
      {
        type: 'typing',
        user_id: current_user.id,
        user_name: current_user.name
      }
    )
  end

  def read
    conversation = Conversation.find(params[:conversation_id])
    
    # Verify user is participant
    return unless conversation.participants.include?(current_user)

    conversation.mark_as_read_by!(current_user)

    ChatChannel.broadcast_to(
      conversation,
      {
        type: 'messages_read',
        user_id: current_user.id,
        read_at: Time.current.iso8601
      }
    )
  end
end
